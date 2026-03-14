import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medicine_try1/model/medicine_model.dart';
import 'package:medicine_try1/screens/med_add_screen.dart';
import 'package:medicine_try1/ui_colors/green.dart';

const addMed_db = 'medicine-database';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({Key? key}) : super(key: key);

  @override
  _MedicationsScreenState createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  late Box<Medicine> _medicineBox;

  @override
  void initState() {
    super.initState();
    _medicineBox = Hive.box<Medicine>(addMed_db);
  }

  // ✅ ADD THIS FUNCTION HERE (DATE FORMAT FIX)
  String formatDate(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final dt = DateTime.parse(dateString);

      return "${dt.day.toString().padLeft(2, '0')}-"
          "${dt.month.toString().padLeft(2, '0')}-"
          "${dt.year}";
    } catch (e) {
      return dateString; // fallback if parsing fails
    }
  }

  Future<void> _deleteMedication(String medId) async {
    await _medicineBox.delete(medId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 227, 226, 226),
        title: const Center(
          child: Text(
            'Medications',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _medicineBox.listenable(),
        builder: (context, Box<Medicine> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No medications added yet.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              Medicine? medicine = box.getAt(index);
              if (medicine == null) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      width: 2,
                      color: greencolor,
                    ),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.medication_rounded,
                          color: greencolor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          medicine.medicineName,
                          style: TextStyle(
                            fontSize: 20,
                            color: greencolor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Frequency: ${medicine.frequency}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Medicine Unit: ${medicine.medicineUnit}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'When : ${medicine.whenm}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Dosage : ${medicine.dosage}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),

                        // ✅ Weekly / Monthly
                        if (medicine.frequency == 'X Day a Week')
                          Text(
                            'Selected Day: ${medicine.selectedDay}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),

                        if (medicine.frequency == 'X Day a Month')
                          Text(
                            'Selected Date: ${medicine.selectedDate}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),

                        // ✅ FIXED DATE FORMAT HERE
                        Text(
                          'Start Date: ${formatDate(medicine.startdate)}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'End Date : ${formatDate(medicine.enddate)}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),

                        Text(
                          'Time : ${medicine.notifications}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Current Stock: ${medicine.currentstock}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            if (medicine.id != null) {
                              await _deleteMedication(medicine.id!);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddMedicine(medicine: medicine),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: greencolor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicine()),
          ).then((_) {
            setState(() {});
          });
        },
        label: const Row(
          children: [
            Icon(Icons.add),
            SizedBox(width: 8),
            Text(
              "Add",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
