import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFF072A40),
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    Row(
                      children: [
                        Text(
                          "Sharjeel Ahmed",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/editprofile');
                            // Your edit logic
                          },
                          icon: Icon(Icons.edit, color: Color(0xFF072A40)),
                        ),
                      ],
                    ),

                    Text(
                      "Lahore, Pakistan",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  animation: true,
                  lineHeight: 12.0,
                  animationDuration: 800,
                  percent: 0.62,
                  center: const Text(
                    "62%",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  progressColor: Color(0xFF072A40),
                  backgroundColor: Colors.grey.shade300,
                  barRadius: const Radius.circular(8),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF072A40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Current Bookings",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF072A40),
                    side: BorderSide(color: Color(0xFF072A40)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text("Previous Bookings"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
