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

  Future<void> _deleteMedication(String medId) async {
    await _medicineBox.delete(medId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 227, 226, 226),
        title: Center(
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
            return Center(child: Text('No medications added yet.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              Medicine? medicine = box.getAt(index);
              if (medicine == null) {
                return SizedBox.shrink();
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
                        Text(
                          medicine.medicineName,
                          style: TextStyle(
                              fontSize: 20,
                              color: greencolor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Frequency: ${medicine.frequency}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Medicine Unit: ${medicine.medicineUnit}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'When : ${medicine.whenm}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Dosage : ${medicine.dosage}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        if (medicine.frequency == 'X Day a Week')
                          Text(
                            'Selected Day: ${medicine.selectedDay}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        if (medicine.frequency == 'X Day a Month')
                          Text(
                            'Selected Date: ${medicine.selectedDate}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        Text(
                          'Start Date: ${medicine.startdate}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text('End Date : ${medicine.enddate}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('Time : ${medicine.notifications}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('Current Stock: ${medicine.currentstock}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Important
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            if (medicine.id != null)
                              await _deleteMedication(medicine.id!);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      AddMedicine(medicine: medicine)),
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
            MaterialPageRoute(builder: (context) => AddMedicine()),
          ).then((_) {
            setState(() {});
          });
        },
        label: Row(
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
