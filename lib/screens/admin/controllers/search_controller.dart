import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/services/admin%20api/fetch_pending_courts_api.dart';

class PendingCourtsSearchController extends GetxController {
  final TextEditingController searchTextController = TextEditingController();
  final RxBool isSearching = false.obs;
  final RxBool showSearchResults = false.obs;
  final RxList<PendingCourt> searchResults = <PendingCourt>[].obs;
  final RxList<PendingCourt> allPendingCourts = <PendingCourt>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    searchTextController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    final query = searchTextController.text.trim();
    if (query.isEmpty) {
      showSearchResults.value = false;
      searchResults.clear();
      update(); // Trigger UI update
    } else {
      _performSearch(query);
    }
  }

  void _performSearch(String query) {
    if (allPendingCourts.isEmpty) return;

    final results = allPendingCourts.where((court) {
      final searchQuery = query.toLowerCase();
      
      // Search in playground name
      if (court.playgroundName.toLowerCase().contains(searchQuery)) {
        return true;
      }
      
      // Search in city
      if (court.city.toLowerCase().contains(searchQuery)) {
        return true;
      }
      
      // Search in town
      if (court.town.toLowerCase().contains(searchQuery)) {
        return true;
      }
      
      // Search in vendor name
      final vendorName = '${court.vendor.firstName} ${court.vendor.lastName}'.toLowerCase();
      if (vendorName.contains(searchQuery)) {
        return true;
      }
      
      // Search in vendor email
      if (court.vendor.email.toLowerCase().contains(searchQuery)) {
        return true;
      }
      
      // Search in court types
      for (final courtItem in court.courts) {
        if (courtItem.courtType.toLowerCase().contains(searchQuery)) {
          return true;
        }
        if (courtItem.courtNumber.toLowerCase().contains(searchQuery)) {
          return true;
        }
      }
      
      return false;
    }).toList();

    searchResults.value = results;
    showSearchResults.value = true;
    update(); // Trigger UI update
  }

  void setPendingCourts(List<PendingCourt> courts) {
    allPendingCourts.value = courts;
    update(); // Trigger UI update
  }

  void clearSearch() {
    searchTextController.clear();
    showSearchResults.value = false;
    searchResults.clear();
    update(); // Trigger UI update
  }

  void showSearchOverlay() {
    showSearchResults.value = true;
    update();
  }

  void hideSearchOverlay() {
    showSearchResults.value = false;
    searchResults.clear();
    update();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      clearSearch();
    }
  }
}
