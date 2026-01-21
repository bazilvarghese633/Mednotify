import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
import 'package:medicine_try1/model/appointment_model.dart';
import 'package:medicine_try1/model/dochistory.dart';
import 'package:medicine_try1/widgets/docaddwidgets/button.dart';
import 'package:medicine_try1/widgets/docaddwidgets/doc_add.dart';
import 'package:medicine_try1/widgets/title_position.dart';

class AppointmentAdd extends StatefulWidget {
  final Function(Appointment) onSave;

  AppointmentAdd({required this.onSave});

  @override
  _AppointmentAddState createState() => _AppointmentAddState();
}

class _AppointmentAddState extends State<AppointmentAdd> {
  final _formKey = GlobalKey<FormState>();
  final _doctorNameController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        print('Save button pressed');

        final newAppointment = Appointment(
          doctorName: _doctorNameController.text,
          hospitalName: _hospitalNameController.text,
          appointmentDate: _selectedDate,
          appointmentTime: '${_selectedTime.hour}:${_selectedTime.minute}',
        );

        final id = DateTime.now().millisecondsSinceEpoch.toString();

        final doctorHistoryEntry = DoctorHistory(
          id: id,
          doctorName: _doctorNameController.text,
          appointmentDate: _selectedDate,
          hospitalName: _hospitalNameController.text,
        );

        final appointmentBox = Hive.box<Appointment>('appointmentBox');
        final historyBox = Hive.box<DoctorHistory>('dochistory');

        await appointmentBox.add(newAppointment);
        await historyBox.add(doctorHistoryEntry);

        widget.onSave(newAppointment);

        Navigator.of(context).pop(newAppointment);
      } catch (e) {
        print("Error saving appointment and history: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving data: $e")),
        );
      }
    }
  }

  void _presentDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _presentTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return CustomScaffolddocadd(
        appBarTitle: "       Add Appointment",
        children: [
          CustomStack(
            child: MedicineTextFieldForm(
              controller: _doctorNameController,
            ),
            title: "Doctor Name",
          ),
          const SizedBox(height: 12),
          CustomStack(
            child: MedicineTextFieldForm(
              controller: _hospitalNameController,
            ),
            title: "Hospital Name",
          ),
          const SizedBox(height: 12),
          CustomStack(
            child: CustomDateFormFielddoc(
              onTap: _presentDatePicker,
              selectDate: _selectedDate,
            ),
            title: "Select Date ",
          ),
          const SizedBox(height: 12),
          CustomStack(
            child: CustomDateFormFielddocTime(
                onTap: _presentTimePicker, selectTime: _selectedTime),
            title: "Select Time",
          ),
          const SizedBox(height: 12),
          CustomSaveButtonDocAdd(saveForm: _saveForm),
        ],
        formKey: _formKey,
        height: screenHeight);
  }
}
