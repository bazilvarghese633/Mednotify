import 'package:flutter/material.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:medicine_try1/screens/testappointment.dart';
import 'package:medicine_try1/screens/medicine_stock.dart';
import 'package:medicine_try1/screens/settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a dummy TestAppointment object

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 227, 226, 226),
        title: const Center(
          child: Text(
            'More',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 20,
                      color: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 60, right: 60, top: 20, bottom: 20),
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TestAppointmentScreen(),
                                  ),
                                );
                              },
                              child: Column(
                                children: const [
                                  Text(
                                    "Test Appointments",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Icon(
                                    color: Colors.white,
                                    IcoFontIcons.laboratory,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Card(
                  elevation: 20,
                  color: const Color.fromARGB(255, 243, 33, 37),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 60, right: 60, top: 20, bottom: 20),
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationDemoScreen(),
                              ),
                            );
                          },
                          child: Column(
                            children: const [
                              Text(
                                "Medicine Stock",
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(
                                color: Colors.white,
                                Icons.local_pharmacy_rounded,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Card(
                  elevation: 20,
                  color: const Color.fromARGB(255, 65, 33, 243),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 60, right: 60, top: 20, bottom: 20),
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsScreen()),
                            );
                          },
                          child: Column(
                            children: const [
                              Text(
                                "Settings",
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(
                                color: Colors.white,
                                Icons.settings,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
