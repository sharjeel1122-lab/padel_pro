import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:padel_pro/services/vendors%20api/vendor_booking_api.dart';

enum BookingFilter { all, today, upcoming, past }

class VendorBookingsController extends GetxController {
  final VendorBookingApi api;

  VendorBookingsController({required this.api});


  final isLoading = false.obs;
  final errorText = RxnString();
  final bookings = <BookingItem>[].obs;
  final search = ''.obs;
  final filter = BookingFilter.all.obs;

  // computed
  List<BookingItem> get filtered {
    final q = search.value.trim().toLowerCase();
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);

    bool matches(BookingItem b) {
      // Search over user name, phone, court, playground
      final haystack = [
        b.userFullName,
        b.userPhone,
        b.courtNumber,
        b.playgroundName,
        b.playgroundLocation
      ].join(' ').toLowerCase();
      if (q.isNotEmpty && !haystack.contains(q)) return false;

      // Filter by date category
      if (filter.value == BookingFilter.all) return true;

      final parts = b.date.split('-');
      DateTime? d;
      if (parts.length == 3) {
        d = DateTime.tryParse(b.date);
      }
      if (d == null) return false;

      final only = DateTime(d.year, d.month, d.day);

      switch (filter.value) {
        case BookingFilter.today:
          return only == todayOnly;
        case BookingFilter.upcoming:
          return only.isAfter(todayOnly);
        case BookingFilter.past:
          return only.isBefore(todayOnly);
        default:
          return true;
      }
    }

    final list = bookings.where(matches).toList();
    // sort: nearest first (date asc, time asc)
    list.sort((a, b) {
      final ad = DateTime.tryParse(a.date) ?? DateTime(2100);
      final bd = DateTime.tryParse(b.date) ?? DateTime(2100);
      final cmp = ad.compareTo(bd);
      if (cmp != 0) return cmp;
      return a.startTime.compareTo(b.startTime);
    });
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    try {
      isLoading.value = true;
      errorText.value = null;
      final list = await api.fetchBookings();
      bookings.assignAll(list);
    } catch (e) {
      errorText.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNow() => fetch();

  void setFilter(BookingFilter f) => filter.value = f;

  void setSearch(String s) => search.value = s;
}
