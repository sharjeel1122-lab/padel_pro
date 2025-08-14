// ignore_for_file: deprecated_member_use

import 'dart:async';                      // <-- POLLING: Timer
import 'dart:developer' as dev;           // logs
import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:padel_pro/services/user role api service/get_recommended_api.dart';
import '../model/ground_model.dart';

class GroundController extends GetxController {
  final popularGrounds = <Ground>[].obs;
  final searchText = ''.obs;
  final userPosition = Rxn<Position>();
  final _api = GetRecommendedClub();

  // Workers (auto log on changes)
  Worker? _groundsWorker;
  Worker? _searchWorker;
  Worker? _posWorker;

  // ---- POLLING additions ----
  Timer? _poller;
  final Duration _pollInterval = const Duration(seconds: 6); // <- change to 5s if you want
  bool _isFetching = false;
  // ---------------------------

  // Filtered + Sorted list
  List<Ground> get filteredGrounds {
    final search = searchText.value.toLowerCase();

    var list = popularGrounds.where((g) {
      return g.title.toLowerCase().contains(search) ||
          g.subtitle.toLowerCase().contains(search);
    }).toList();

    if (userPosition.value != null) {
      double distanceTo(Ground g) {
        if (g.lat == null || g.lng == null) return double.infinity;
        return Geolocator.distanceBetween(
          userPosition.value!.latitude,
          userPosition.value!.longitude,
          g.lat!, g.lng!,
        );
      }
      list.sort((a, b) => distanceTo(a).compareTo(distanceTo(b)));
    }

    if (kDebugMode) {
      dev.log('filteredGrounds -> ${list.length} items (search="${searchText.value}")',
          name: 'GroundController');
    }
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) dev.log('onInit()', name: 'GroundController');

    // Workers to watch state changes
    _groundsWorker = ever<List<Ground>>(popularGrounds, (list) {
      if (kDebugMode) {
        dev.log('popularGrounds changed: ${list.length} items', name: 'GroundController');
        if (list.isNotEmpty) {
          final g = list.first;
          dev.log('first: ${g.title} | rec=${g.recommended} | imgs=${g.images.length}',
              name: 'GroundController');
        }
      }
    });

    _searchWorker = ever<String>(searchText, (s) {
      if (kDebugMode) dev.log('searchText="$s"', name: 'GroundController');
    });

    _posWorker = ever<Position?>(userPosition, (pos) {
      if (kDebugMode) {
        dev.log('userPosition=${pos != null ? "${pos.latitude},${pos.longitude}" : "null"}',
            name: 'GroundController');
      }
    });

    fetchFromApi();     // initial load
    _getUserLocation(); // location
    _startPolling();    // <-- start silent polling
  }

  @override
  void onClose() {
    _groundsWorker?.dispose();
    _searchWorker?.dispose();
    _posWorker?.dispose();

    // ---- POLLING cleanup ----
    _poller?.cancel();
    _poller = null;
    // -------------------------
    super.onClose();
  }

  // PUBLIC: Manual refresh (UI se pull-to-refresh ya retry pe call kar sakhte ho)
  Future<void> fetchFromApi({bool quiet = false}) async {
    if (_isFetching) return; // overlap se bacho
    _isFetching = true;

    if (!quiet && kDebugMode) dev.log('fetchFromApi() -> start', name: 'GroundController');
    try {
      final data = await _api.fetchRecommended();
      if (!quiet && kDebugMode) {
        dev.log('fetchFromApi() -> got ${data.length} items', name: 'GroundController');
      }

      final onlyRecommended = data.where((g) => g.recommended).toList();
      if (!quiet && kDebugMode) {
        dev.log('recommended filtered -> ${onlyRecommended.length}', name: 'GroundController');
      }

      // Optional: Avoid unnecessary UI rebuilds (only update if changed)
      if (_listsAreDifferent(popularGrounds, onlyRecommended)) {
        popularGrounds.assignAll(onlyRecommended);
      }

      if (!quiet && kDebugMode && onlyRecommended.isNotEmpty) {
        final g = onlyRecommended.first;
        dev.log('sample -> ${g.title} (${g.subtitle}) | rating=${g.rating} | imgs=${g.images.length}',
            name: 'GroundController');
      }
    } catch (e, st) {
      if (!quiet && kDebugMode) {
        dev.log('fetchFromApi() ERROR: $e', name: 'GroundController', stackTrace: st);
      }
      // quiet mode me list clear na karo (UI flash avoid)
      if (!quiet) popularGrounds.clear();
    } finally {
      if (!quiet && kDebugMode) dev.log('fetchFromApi() -> end', name: 'GroundController');
      _isFetching = false;
    }
  }

  // ---- POLLING helpers ----
  void _startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(_pollInterval, (_) async {
      // silent refetch (quiet = true) -> kam logs, no list clear on error
      await fetchFromApi(quiet: true);
    });
    if (kDebugMode) {
      dev.log('Polling started every ${_pollInterval.inSeconds}s', name: 'GroundController');
    }
  }
  // Basic shallow compare by length + first/last ids (cheap); adjust if needed
  bool _listsAreDifferent(List<Ground> a, List<Ground> b) {
    if (identical(a, b)) return false;
    if (a.length != b.length) return true;
    if (a.isEmpty) return false;
    // compare first & last titles/ids quickly
    final aFirst = a.first.id.isNotEmpty ? a.first.id : a.first.title;
    final bFirst = b.first.id.isNotEmpty ? b.first.id : b.first.title;
    final aLast  = a.last.id.isNotEmpty  ? a.last.id  : a.last.title;
    final bLast  = b.last.id.isNotEmpty  ? b.last.id  : b.last.title;
    return aFirst != bFirst || aLast != bLast;
  }
  // -------------------------

  Future<void> _getUserLocation() async {
    if (kDebugMode) dev.log('_getUserLocation() start', name: 'GroundController');

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) dev.log('Location service disabled', name: 'GroundController');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) dev.log('Location deniedForever', name: 'GroundController');
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (kDebugMode) dev.log('Location permission denied', name: 'GroundController');
        return;
      }
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userPosition.value = position;
      if (kDebugMode) {
        dev.log('Got position: ${position.latitude}, ${position.longitude}', name: 'GroundController');
      }
    } catch (e) {
      if (kDebugMode) dev.log('getCurrentPosition ERROR: $e', name: 'GroundController');
    } finally {
      if (kDebugMode) dev.log('_getUserLocation() end', name: 'GroundController');
    }
  }

  void updateSearch(String value) {
    searchText.value = value;
  }
}
