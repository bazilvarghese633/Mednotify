import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medicine_try1/model/test_history.dart';
import 'package:medicine_try1/model/testappointment.dart';
import 'package:medicine_try1/ui_colors/green.dart';
import 'package:medicine_try1/widgets/title_position.dart';

class TestAppointmentAdd extends StatefulWidget {
  final void Function(TestAppointment testAppointment) onSave;
  final TestAppointment? appointment;

  // 🔥 KEY is optional (null = add, not null = edit)
  final dynamic appointmentKey;

  const TestAppointmentAdd({
    super.key,
    required this.onSave,
    this.appointment,
    required this.appointmentKey,
  });

  @override
  State<TestAppointmentAdd> createState() => _TestAppointmentAddState();
}

class _TestAppointmentAddState extends State<TestAppointmentAdd> {
  final _formKey = GlobalKey<FormState>();
  final _testNameController = TextEditingController();
  final _laboratoryNameController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _selectedImages = [];

  @override
  void initState() {
    super.initState();

    // ✅ EDIT MODE PREFILL
    if (widget.appointment != null) {
      _testNameController.text = widget.appointment!.testName;
      _laboratoryNameController.text = widget.appointment!.laboratoryName;
      _selectedDate = widget.appointment!.date;
      _selectedTime = widget.appointment!.time;
      _selectedImages = List<String>.from(widget.appointment!.images);
    }
  }

  @override
  void dispose() {
    _testNameController.dispose();
    _laboratoryNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _pickImages() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an option'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context);

                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.camera);

                    if (pickedFile != null) {
                      setState(() {
                        _selectedImages.add(pickedFile.path);
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () async {
                    Navigator.pop(context);

                    final pickedFiles = await ImagePicker().pickMultiImage();

                    if (pickedFiles.isNotEmpty) {
                      setState(() {
                        _selectedImages.addAll(
                          pickedFiles.map((file) => file.path).toList(),
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedAppointment = TestAppointment(
        testName: _testNameController.text.trim(),
        laboratoryName: _laboratoryNameController.text.trim(),
        date: _selectedDate,
        time: _selectedTime,
        images: _selectedImages,
      );

      final appointmentBox = Hive.box<TestAppointment>('testAppointmentsBox');

      // ✅ EDIT MODE (update using KEY)
      if (widget.appointmentKey != null) {
        await appointmentBox.put(widget.appointmentKey, updatedAppointment);
      } else {
        // ✅ ADD MODE
        await appointmentBox.add(updatedAppointment);

        // ✅ Add to history only for NEW appointment
        final id = DateTime.now().millisecondsSinceEpoch.toString();

        final testHistoryEntry = TestHistory(
          id: id,
          testName: _testNameController.text.trim(),
          testDate: _selectedDate,
          results: _laboratoryNameController.text.trim(),
        );

        final historyBox = Hive.box<TestHistory>('testhistory');
        await historyBox.add(testHistoryEntry);
      }

      Navigator.pop(context, updatedAppointment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.appointmentKey != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 227, 226, 226),
        title: Center(
          child: Text(
            isEdit
                ? "Edit Test Appointment      "
                : "Add Test Appointment      ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomStack(
                  title: "Test Name",
                  child: MedicineTextFieldForm(
                    controller: _testNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the test name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 12),

                CustomStack(
                  title: 'Laboratory Name',
                  child: MedicineTextFieldForm(
                    controller: _laboratoryNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the laboratory name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ DATE
                Row(
                  children: [
                    const Text('Select Date: '),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _pickDate,
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),

                // ✅ TIME
                Row(
                  children: [
                    const Text('Select Time: '),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _pickTime,
                      child: Text(
                        _selectedTime.format(context),
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ✅ IMAGES SECTION
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Images: '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            List.generate(_selectedImages.length, (index) {
                          final imagePath = _selectedImages[index];

                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(imagePath),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.grey.shade200,
                                      ),
                                      child: const Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                              ),

                              // ❌ Remove Single Image Button
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ✅ IMAGE BUTTONS
                Row(
                  children: [
                    TextButton(
                      onPressed: _pickImages,
                      child: const Text(
                        'Pick Images',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedImages.clear();
                        });
                      },
                      child: const Text(
                        "Clear",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ✅ SAVE BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: greencolor),
                  onPressed: _saveForm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      isEdit ? 'UPDATE' : 'SAVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
