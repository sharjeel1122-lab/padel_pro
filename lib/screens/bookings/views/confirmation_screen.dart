import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/bookingcontroller.dart';

class ConfirmationScreen extends StatelessWidget {
  final double price;
  final BookingController controller = Get.find();

  ConfirmationScreen({super.key, required this.price});

  int get courtCharges => controller.selectedCourtPrice.value;
  int get advancePaid => (courtCharges / 2).round();
  int get remaining => courtCharges - advancePaid;

  @override
  Widget build(BuildContext context) {
    final selectedDate = controller.dates[controller.selectedDateIndex.value];
    final courtName = "Court ${controller.selectedCourtIndex.value + 1}";
    final duration = controller.selectedDuration.value;
    final time = controller.selectedTime.value ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Confirmation', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF072A40),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingDetailsCard(selectedDate, courtName, duration, time),
            const SizedBox(height: 24),
            _buildPaymentDetailsCard(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard(DateTime date, String court, int duration, String time) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Booking Details",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF072A40),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.calendar_today,
                "${_formatDay(date.weekday)}, ${date.day} ${_formatMonth(date.month)} ${date.year}"),
            _buildDetailRow(Icons.access_time, "$time - ${_calculateEndTime(time, duration)}"),
            _buildDetailRow(Icons.sports_tennis, "Padel, Club Padel ($court)"),
            _buildDetailRow(Icons.timer, "$duration minutes"),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment Details",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF072A40),
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentRow("Court Charges", "Rs $courtCharges"),
            _buildPaymentRow("Platform Fee", "Rs 200 FREE", isFree: true),
            const Divider(),
            _buildPaymentRow("Advance Paid (50%)", "Rs $advancePaid"),
            _buildPaymentRow("Remaining (50%)", "Rs $remaining"),
            const Divider(),
            _buildPaymentRow("Total Amount", "Rs $courtCharges", isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.defaultDialog(
                title: "🎉 Booking Done!",
                titleStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.green[700],
                ),
                content: Column(
                  children: [
                    const Icon(Icons.check_circle, size: 60, color: Colors.green),
                    const SizedBox(height: 10),
                    Text(
                      "Your court has been successfully booked.",
                      style: GoogleFonts.poppins(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                confirm: ElevatedButton(
                  onPressed: () {
                    Get.until((route) => route.isFirst); // Back to home
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF072A40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("Back to Home", style: GoogleFonts.poppins(color: Colors.white)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF072A40),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Confirm Booking",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF072A40), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isFree = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isFree ? Colors.green : (isTotal ? const Color(0xFF072A40) : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDay(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String _formatMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  String _calculateEndTime(String startTime, int duration) {
    try {
      final timeParts = startTime.split(' ');
      final period = timeParts[1];
      final hourMinute = timeParts[0].split(':');
      int hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);

      if (period == 'PM' && hour != 12) hour += 12;

      final startDateTime = DateTime(0, 0, 0, hour, minute);
      final endDateTime = startDateTime.add(Duration(minutes: duration));

      String endPeriod = endDateTime.hour >= 12 ? 'PM' : 'AM';
      int endHour = endDateTime.hour > 12 ? endDateTime.hour - 12 : endDateTime.hour;
      if (endHour == 0) endHour = 12;

      return '$endHour:${endDateTime.minute.toString().padLeft(2, '0')} $endPeriod';
    } catch (e) {
      return '';
    }
  }
}
