import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../views/confirmation_screen.dart';

class BookingController extends GetxController {
  var selectedDateIndex = 0.obs;
  var selectedCourtIndex = 0.obs;
  var selectedDuration = 90.obs;
  var selectedTime = RxnString();
  var selectedCourtPrice = 0.obs;
  final currentMonth = DateTime.now().month.obs;
  final dates = List.generate(31, (index) => DateTime.now().add(Duration(days: index))).obs;

  final availableTimesPerCourt = {
    0: ['1:30 PM', '2:30 PM', '4:00 PM', '6:30 PM', '8:00 PM'],
    1: ['2:00 PM', '3:00 PM', '5:00 PM', '7:30 PM', '10:00 PM'],
    2: ['1:30 PM', '3:30 PM', '4:30 PM', '8:30 PM'],
    3: ['3:00 PM', '4:30 PM', '6:00 PM', '9:00 PM']
  };

  void confirmBooking() {
    Get.defaultDialog(
      title: "Confirm Booking",
      titleStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: Color(0xFF072A40),
        fontSize: 20,
      ),
      content: Column(
        children: [
          Text(
            "Are you sure you want to book this court?",
            style: GoogleFonts.poppins(),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  _showBookingDetails();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF072A40),
                ),
                child: Text(
                  "Continue",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBookingDetails() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Add Players",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            _buildBookingSummary(),
            SizedBox(height: 20),
            _buildTermsAndConditions(),
            SizedBox(height: 20),
            _buildPaymentButton(),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Booking Summary",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Wed 23 Jul, 08:30 PM - 10:30 PM",
            style: GoogleFonts.poppins(),
          ),
          Text(
            "Padel, Club Padel (Court 1)",
            style: GoogleFonts.poppins(),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Terms & Conditions",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "- Do not disconnect from the internet during the transaction",
          style: GoogleFonts.poppins(),
        ),
        Text(
          "- Avoid closing the app while the transaction is in progress",
          style: GoogleFonts.poppins(),
        ),
        Text(
          "- Your booking will be confirmed once the process is complete",
          style: GoogleFonts.poppins(),
        ),
        Text(
          "- If payment fails, contact club representative",
          style: GoogleFonts.poppins(),
        ),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return Column(
      children: [
        Divider(),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "Rs 13,000",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showPaymentOptions,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF072A40),
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Book Now",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPaymentOptions() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Payment Options",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _buildCourtCharges(),
            SizedBox(height: 20),
            _buildPaymentMethods(),
            SizedBox(height: 20),
            _buildFinalPaymentButton(),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildCourtCharges() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Court Charges",
              style: GoogleFonts.poppins(),
            ),
            Text(
              "Rs 13,000",
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Platform Fee",
              style: GoogleFonts.poppins(),
            ),
            Text(
              "Rs 200 FREE",
              style: GoogleFonts.poppins(color: Colors.green),
            ),
          ],
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Advance Payment (50%)",
              style: GoogleFonts.poppins(),
            ),
            Text(
              "Rs 6,500",
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Remaining (50%)",
              style: GoogleFonts.poppins(),
            ),
            Text(
              "Rs 6,500",
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment Methods",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ListTile(
          leading: Icon(Icons.payment, color: Color(0xFF072A40)),
          title: Text(
            "PayFast",
            style: GoogleFonts.poppins(),
          ),
          subtitle: Text(
            "Partial (50%)",
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          trailing: Radio(
            value: "payfast",
            groupValue: "payfast",
            onChanged: (value) {},
            activeColor: Color(0xFF072A40),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalPaymentButton() {
    return Column(
      children: [
        Divider(),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "Rs 6,500",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.back();
              Get.to(() => ConfirmationScreen(price: 6500.0));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF072A40),
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Proceed to Confirm",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

}