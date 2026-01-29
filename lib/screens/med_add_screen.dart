import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/widgets.dart';
import 'package:medicine_try1/model/medicine_model.dart';
import 'package:medicine_try1/screens/hive_db_functions/medicine_db.dart';
import 'package:medicine_try1/ui_colors/green.dart';
import 'package:medicine_try1/widgets/coloum_custom.dart';
import 'package:medicine_try1/widgets/custom_dropdown.dart';
import 'package:medicine_try1/widgets/scaffold.dart';
import 'package:medicine_try1/widgets/title_position.dart';
import 'package:intl/intl.dart';

// ignore: unused_import
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class AddMedicine extends StatefulWidget {
  final Medicine? medicine;
  const AddMedicine({Key? key, this.medicine}) : super(key: key);

  @override
  State<AddMedicine> createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  final _medicationNameController = TextEditingController();

  // ignore: unused_field
  String _medicationName = '';
  String _selectedUnit = 'Tabs';
  String _frequency = 'Everyday';
  bool _showWeekDaySelection = false;
  DateTime? _selectedDate;
  DateTime? _startedDate;
  DateTime? _endedDate;
  List<String> _selectedDays = [];
  List<Map<String, dynamic>> _medications = [];
  List<TimeOfDay?> _notifications = [];
  TimeOfDay? _selectedTime;

  List<String> _units = ['Tabs', 'TBspoon', 'ml', 'Drops'];
  List<String> _frequencies = ['Everyday', 'X Day a Week', 'X Day a Month'];
  List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  MedicineDb med = MedicineDb();

  List<String> _dropdownWhen = [
    'After Breakfast',
    'Before Breakfast',
    'Before Lunch',
    'After Lunch',
    'Before Dinner',
    'After Dinner'
  ];

  List<int> _dosageList = List<int>.generate(100, (i) => i + 1);

  int _selectedStock = 1;
  List<int> _currentStock = List.generate(100, (index) => index + 1);

  int _selectedDe = 1;
  List<int> _deStock = List.generate(100, (index) => index + 1);

  @override
  void initState() {
    super.initState();

    if (widget.medicine != null) {
      final med = widget.medicine!;
      _medicationNameController.text = med.medicineName;
      _selectedUnit = med.medicineUnit;
      _frequency = med.frequency;
      _showWeekDaySelection = _frequency == 'X Day a Week';
      _selectedDays = med.selectedDay != null
          ? med.selectedDay!.replaceAll('[', '').replaceAll(']', '').split(',')
          : [];
      _selectedDate = med.selectedDate != null && med.selectedDate!.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(med.selectedDate!)
          : null;
      _startedDate = med.startdate.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(med.startdate)
          : null;
      _endedDate = med.enddate.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(med.enddate)
          : null;
      _selectedStock = int.tryParse(med.currentstock) ?? 1;
      _selectedDe = int.tryParse(med.destock) ?? 1;

      _medications = [
        {
          'when': med.whenm,
          'dosage': int.tryParse(med.dosage) ?? 1,
        }
      ];

      _notifications = med.notifications.split(', ').map((timeStr) {
        final dt = DateFormat.jm().parse(timeStr);
        return TimeOfDay(hour: dt.hour, minute: dt.minute);
      }).toList();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _startDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startedDate = picked;
      });
    }
  }

  Future<void> _endDate(BuildContext context) async {
    if (_startedDate == null) {
      // Show an alert or some feedback that start date must be selected first
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a start date first')),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _startedDate!, // Ensure the picker starts from the start date
      firstDate:
          _startedDate!, // This ensures the end date is after the start date
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _endedDate) {
      setState(() {
        _endedDate = picked;
      });
    }
  }

  void _showTimePicker(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notifications[index] ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _notifications[index] = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final formatter = DateFormat.jm('en_US');
    return formatter.format(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      time.hour,
      time.minute,
    ));
  }

  void _addMedication() {
    setState(() {
      _medications.add({
        'name': _medicationNameController.text,
        'unit': _selectedUnit,
        'frequency': _frequency,
        'days': _selectedDays,
        'date': _selectedDate,
        'when': _dropdownWhen.first,
        'dosage': 1,
        'currentStock': 1,
        'destock': 1,
      });
    });
  }

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  void _addNotifications() {
    setState(() {
      _notifications.add(_selectedTime);
      _selectedTime = null;
    });
  }

  void _deleteNotifications(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  void _deleteMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  void _updateMedicationWhen(int index, String newValue) {
    setState(() {
      _medications[index]['when'] = newValue;
    });
  }

  void _updateMedicationDosage(int index, int newValue) {
    setState(() {
      _medications[index]['dosage'] = newValue;
    });
  }

  Widget _buildSelectedItem(String item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: item.split(' ').map((word) => Text(word)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldmedadd(
      appBarTitle: "          Add Medication",
      children: [
        CustomStack(
          child: MedicineTextFieldForm(controller: _medicationNameController),
          title: "Medicine Name",
        ),
        CustomStack(
          child: CustomDropdown(
            value: _selectedUnit,
            items: _units,
            onChanged: (String? newValue) {
              setState(() {
                _selectedUnit = newValue!;
              });
            },
          ),
          title: "Medicine Unit",
        ),
        CustomStack(
          child: CustomDropdown(
            value: _frequency,
            items: _frequencies,
            onChanged: (String? newValue) {
              setState(() {
                _frequency = newValue!;
                _showWeekDaySelection = _frequency == 'X Day a Week';
                _selectedDays = [];
              });
            },
          ),
          title: "Frequency",
        ),
        if (_showWeekDaySelection)
          CustomStack(
            child: CustomDropdown(
              items: _weekDays,
              onChanged: (String? newValue) {
                if (newValue != null && !_selectedDays.contains(newValue)) {
                  setState(() {
                    _selectedDays.add(newValue);
                  });
                }
              },
            ),
            title: "Select a Day",
          )
        else if (_frequency == 'X Day a Month')
          CustomStack(
            child: CustomDateFormField(
              selectDate: _selectDate,
              controller: TextEditingController(
                text: _selectedDate != null
                    ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
                    : '',
              ),
            ),
            title: "Select a Date",
          ),
        CustomColoumStack(
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return ListTile(
                      title: sheduleTitleRow(),
                      subtitle: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: DropdownButton<String>(
                              value: _medications[index]['when'],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _updateMedicationWhen(index, newValue!);
                                });
                              },
                              items: _dropdownWhen
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: _buildSelectedItem(value),
                                );
                              }).toList(),
                              iconEnabledColor: greencolor,
                              iconSize: 30,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 13),
                            child: DropdownButton<int>(
                              menuMaxHeight: 250,
                              value: _medications[index]['dosage'],
                              onChanged: (int? newValue) {
                                setState(() {
                                  _updateMedicationDosage(index, newValue!);
                                });
                              },
                              items: _dosageList
                                  .map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString()),
                                );
                              }).toList(),
                              iconEnabledColor: greencolor,
                              iconSize: 30,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () => _deleteMedication(index),
                      ),
                    );
                  },
                  childCount: _medications.length,
                ),
              ),
            ],
          ),
          titleS: "Schedule",
          onPressed: _addMedication,
        ),
        SizedBox(
          height: 20,
        ),
        CustomColoumStack(
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return ListTile(
                      title: notificationTitleRow(),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => _showTimePicker(index),
                            child: Text(
                              _notifications[index]?.format(context) ??
                                  'Select Time',
                              style: TextStyle(
                                color: _notifications[index] != null
                                    ? Color.fromARGB(255, 35, 239, 39)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () => _deleteNotifications(index),
                      ),
                    );
                  },
                  childCount: _notifications.length,
                ),
              ),
            ],
          ),
          titleS: "Notification Time",
          onPressed: _addNotifications,
        ),
        SizedBox(
          height: 20,
        ),
        CustomStack(
          child: CustomDateFormField(
            selectDate: _startDate,
            controller: TextEditingController(
              text: _startedDate != null
                  ? DateFormat('dd-MM-yyyy').format(_startedDate!)
                  : '',
            ),
          ),
          title: "Start Date",
        ),
        CustomStack(
          child: CustomDateFormField(
            selectDate: _endDate,
            controller: TextEditingController(
              text: _endedDate != null
                  ? DateFormat('dd-MM-yyyy').format(_endedDate!)
                  : '',
            ),
          ),
          title: "End Date",
        ),
        CustomStockColum(
          row1: CurrentStockDropdown(
            items: _currentStock,
            onChanged: (int? newValue) {
              setState(() {
                _selectedStock = newValue!;
              });
            },
            selectedUnit: _selectedUnit,
            borderColor: greencolor,
            value: _selectedStock,
          ),
          row2: CurrentStockDropdown(
            items: _deStock,
            onChanged: (int? newValue) {
              setState(() {
                _selectedDe = newValue!;
              });
            },
            selectedUnit: _selectedUnit,
            borderColor: Color.fromARGB(255, 248, 23, 23),
            value: _selectedDe,
          ),
          titleS: "Medicine Stock",
        ),
        MedicationSaveButton(
          onPressed: () async {
            final medToSave = Medicine(
              id: widget.medicine?.id ??
                  DateTime.now().microsecondsSinceEpoch.toString(),
              medicineName: _medicationNameController.text,
              medicineUnit: _selectedUnit,
              frequency: _frequency,
              selectedDay: _selectedDays.toString(),
              selectedDate: _selectedDate != null
                  ? dateFormat.format(_selectedDate!)
                  : '',
              whenm: _medications.first['when'].toString(),
              dosage: _medications.first['dosage'].toString(),
              notifications:
                  _notifications.map((time) => _formatTime(time!)).join(', '),
              startdate:
                  _startedDate != null ? dateFormat.format(_startedDate!) : '',
              enddate: _endedDate != null ? dateFormat.format(_endedDate!) : '',
              currentstock: _selectedStock.toString(),
              destock: _selectedDe.toString(),
            );

            if (widget.medicine != null) {
              // Edit mode
              await med.updateMedicine(medToSave);
            } else {
              // Add new
              await med.addMedicienDetails(medToSave);
            }

            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
