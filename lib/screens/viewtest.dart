import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:medicine_try1/model/testappointment.dart';
import 'package:medicine_try1/screens/add_test.dart';
import '../ui_colors/green.dart';

class ViewTestAppointmentScreen extends StatelessWidget {
  final TestAppointment testAppointment;

  // ✅ key instead of index
  final dynamic appointmentKey;

  const ViewTestAppointmentScreen({
    super.key,
    required this.testAppointment,
    required this.appointmentKey,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd-MM-yyyy').format(testAppointment.date);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 227, 226, 226),
        title: const Center(
          child: Text(
            'View Test Appointment',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          // ✅ EDIT
          IconButton(
            icon: const Icon(Icons.edit, color: greencolor),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TestAppointmentAdd(
                    onSave: (val) {},
                    appointment: testAppointment,
                    appointmentKey: appointmentKey, // ✅ REQUIRED FIX
                  ),
                ),
              );

              // after edit -> go back
              Navigator.pop(context);
            },
          ),

          // ✅ DELETE
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirmDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text(
                      'Are you sure you want to delete this appointment?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmDelete == true) {
                final box = Hive.box<TestAppointment>('testAppointmentsBox');

                // ✅ Delete using KEY
                await box.delete(appointmentKey);

                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(width: 2, color: greencolor),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testAppointment.testName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _infoRow(
                    icon: Icons.local_hospital,
                    title: "Lab",
                    value: testAppointment.laboratoryName,
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    icon: Icons.calendar_month,
                    title: "Date",
                    value: dateText,
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    icon: Icons.access_time,
                    title: "Time",
                    value: testAppointment.time.format(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Images",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (testAppointment.images.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(width: 1, color: Colors.grey.shade300),
                ),
                child: const Text(
                  "No images added",
                  style: TextStyle(fontSize: 16),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: testAppointment.images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final imagePath = testAppointment.images[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ImageViewer(imagePath: imagePath),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, size: 30),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: greencolor),
        const SizedBox(width: 10),
        Text(
          "$title: ",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class ImageViewer extends StatelessWidget {
  final String imagePath;

  const ImageViewer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 227, 226, 226),
        title: const Text('Image Viewer'),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
            File(imagePath),
            errorBuilder: (context, error, stackTrace) {
              return const Text("Image not found");
            },
          ),
        ),
      ),
    );
  }
}
