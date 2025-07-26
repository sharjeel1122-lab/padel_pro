import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../login_screen.dart';

class PendingApprovalScreen extends StatelessWidget {
  final String contactNumber;

  const PendingApprovalScreen({super.key, required this.contactNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Approval Pending')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 80, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              'Your account is under review',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Please wait for admin approval. We will notify you once your account is approved.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Text(
              'For any queries, contact:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final url = 'tel:$contactNumber';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  Get.snackbar('Error', 'Could not launch phone app');
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    contactNumber,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Get.offAll(() => LoginScreen()); // Assuming you have a login screen
              },
              child: Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}