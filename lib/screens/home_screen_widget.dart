import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:medicine_try1/ui_colors/green.dart';
import 'package:medicine_try1/utils/colors_util.dart';
import 'package:medicine_try1/utils/date_utils.dart' as date_util;
import 'package:medicine_try1/model/medicine_model.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late double width;
  late double height;
  late ScrollController scrollController;
  late List<DateTime> currentMonthList;
  late DateTime currentDateTime;
  late Box<Medicine> medicineBox;
  late List<Medicine> filteredMedicines;
  late Box<bool> intakeBox;

  @override
  void initState() {
    super.initState();
    currentDateTime = DateTime.now();
    currentMonthList = date_util.DateUtils.daysInMonth(currentDateTime);
    currentMonthList.sort((a, b) => a.day.compareTo(b.day));
    currentMonthList = currentMonthList.toSet().toList();
    scrollController = ScrollController();

    // Initialize the medicine box
    medicineBox = Hive.box<Medicine>('medicine-database');
    intakeBox = Hive.box<bool>('medicine-intake');
    filterMedicines(currentDateTime); // Pass the current date
  }

  void filterMedicines(DateTime selectedDate) {
    filteredMedicines = medicineBox.values.where((medicine) {
      final DateTime startDate = DateTime.parse(medicine.startdate);
      final DateTime endDate = DateTime.parse(medicine.enddate);
      return (selectedDate.isAfter(startDate) &&
              selectedDate.isBefore(endDate)) ||
          selectedDate.isAtSameMomentAs(startDate) ||
          selectedDate.isAtSameMomentAs(endDate);
    }).toList();
  }

// Create a key for medicine+date
  String intakeKey(Medicine medicine) {
    return '${medicine.id}_${DateFormat('yyyy-MM-dd').format(currentDateTime)}';
  }

// Check if medicine is taken for the selected date
  bool isTakenToday(Medicine medicine) {
    return intakeBox.get(intakeKey(medicine), defaultValue: false)!;
  }

  Future<void> markMedicineTaken(Medicine medicine) async {
    if (isTakenToday(medicine)) return; // already taken

    final stock = int.tryParse(medicine.currentstock) ?? 0;
    if (stock <= 0) return;

    final updated = Medicine(
      id: medicine.id,
      medicineName: medicine.medicineName,
      medicineUnit: medicine.medicineUnit,
      frequency: medicine.frequency,
      selectedDate: medicine.selectedDate,
      selectedDay: medicine.selectedDay,
      endDate: medicine.endDate,
      whenm: medicine.whenm,
      dosage: medicine.dosage,
      notifications: medicine.notifications,
      startdate: medicine.startdate,
      enddate: medicine.enddate,
      currentstock: (stock - 1).toString(), // decrease stock
      destock: medicine.destock,
    );

    await medicineBox.put(medicine.id, updated);
    await intakeBox.put(intakeKey(medicine), true); // mark taken

    setState(() {
      filterMedicines(currentDateTime);
    });
  }

  Future<void> undoMedicineTaken(Medicine medicine) async {
    if (!isTakenToday(medicine)) return;

    final stock = int.tryParse(medicine.currentstock) ?? 0;

    final updated = Medicine(
      id: medicine.id,
      medicineName: medicine.medicineName,
      medicineUnit: medicine.medicineUnit,
      frequency: medicine.frequency,
      selectedDate: medicine.selectedDate,
      selectedDay: medicine.selectedDay,
      endDate: medicine.endDate,
      whenm: medicine.whenm,
      dosage: medicine.dosage,
      notifications: medicine.notifications,
      startdate: medicine.startdate,
      enddate: medicine.enddate,
      currentstock: (stock + 1).toString(), // restore stock
      destock: medicine.destock,
    );

    await medicineBox.put(medicine.id, updated);
    await intakeBox.put(intakeKey(medicine), false); // mark not taken

    setState(() {
      filterMedicines(currentDateTime);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToCurrentDay();
    });
  }

  void scrollToCurrentDay() {
    final bool isCurrentMonth = currentDateTime.month == DateTime.now().month &&
        currentDateTime.year == DateTime.now().year;

    final int dayIndex = isCurrentMonth
        ? currentMonthList.indexWhere((date) => date.day == currentDateTime.day)
        : 0; // Use the first day index if not the current month

    if (dayIndex != -1 && currentMonthList.isNotEmpty) {
      final double itemWidth = 70.0; // Width of each item in the list
      final double screenWidth = MediaQuery.of(context).size.width;
      final double centerOffset =
          (screenWidth - itemWidth) / 2.0; // Offset to center the day
      final double scrollOffset =
          dayIndex * itemWidth - centerOffset; // Scroll to center
      scrollController.animateTo(
        scrollOffset,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget titleView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 25, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                currentDateTime = DateTime(
                    currentDateTime.year, currentDateTime.month - 1, 1);
                currentMonthList =
                    date_util.DateUtils.daysInMonth(currentDateTime);
                currentMonthList.sort((a, b) => a.day.compareTo(b.day));
                currentMonthList = currentMonthList.toSet().toList();
                filterMedicines(currentDateTime);
              });
              scrollToCurrentDay(); // Scroll to the appropriate day
            },
          ),
          Text(
            date_util.DateUtils.months[currentDateTime.month - 1] +
                ' ' +
                currentDateTime.year.toString(),
            style: const TextStyle(
                color: Color.fromARGB(255, 47, 48, 47),
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                currentDateTime = DateTime(
                    currentDateTime.year, currentDateTime.month + 1, 1);
                currentMonthList =
                    date_util.DateUtils.daysInMonth(currentDateTime);
                currentMonthList.sort((a, b) => a.day.compareTo(b.day));
                currentMonthList = currentMonthList.toSet().toList();
                filterMedicines(currentDateTime);
              });
              scrollToCurrentDay(); // Scroll to the appropriate day
            },
          ),
        ],
      ),
    );
  }

  Widget horizontalCapsuleListView() {
    return Container(
      width: width,
      height: 80,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: currentMonthList.length,
        itemBuilder: (BuildContext context, int index) {
          return capsuleView(index);
        },
      ),
    );
  }

  Widget capsuleView(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            currentDateTime = currentMonthList[index];
            filterMedicines(currentDateTime);
          });
        },
        child: Container(
          width: 60,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: (currentMonthList[index].day != currentDateTime.day)
                  ? [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.5)
                    ]
                  : [
                      greencolor,
                      greencolor,
                      greencolor,
                    ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(0.0, 1.0),
              stops: const [0.0, 0.5, 1.0],
              tileMode: TileMode.clamp,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                offset: Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 2,
                color: Colors.black12,
              )
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  currentMonthList[index].day.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: (currentMonthList[index].day != currentDateTime.day)
                        ? HexColor("465876")
                        : Colors.white,
                  ),
                ),
                Text(
                  date_util
                      .DateUtils.weekdays[currentMonthList[index].weekday - 1],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: (currentMonthList[index].day != currentDateTime.day)
                        ? HexColor("465876")
                        : Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget topView() {
    return Container(
      height: height * 0.24,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HexColor("#f3f6f4 ").withOpacity(0.7),
            HexColor("#f3f6f4 ").withOpacity(0.5),
            HexColor("#f3f6f4 ").withOpacity(0.3)
          ],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(0.0, 1.0),
          stops: const [0.0, 0.5, 1.0],
          tileMode: TileMode.clamp,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black12,
            offset: Offset(4, 4),
            spreadRadius: 2,
          )
        ],
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          titleView(),
          horizontalCapsuleListView(),
        ],
      ),
    );
  }

  Widget medicineDetailsView(Medicine medicine) {
    final int stock = int.tryParse(medicine.currentstock) ?? 0;
    final bool taken = isTakenToday(medicine);
    final bool outOfStock = stock == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(
          width: 2,
          color: greencolor,
        ),
        boxShadow: const [
          BoxShadow(
            offset: Offset(2, 2),
            blurRadius: 4,
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top info row
          Row(
            children: [
              Icon(Icons.timer, color: greencolor, size: 36),
              const SizedBox(width: 10),
              Text(
                '${medicine.notifications} / ${medicine.whenm}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: greencolor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Main row: check button + medicine info
          Row(
            children: [
              // Check / out of stock button
              GestureDetector(
                onTap: outOfStock
                    ? null
                    : () {
                        taken
                            ? undoMedicineTaken(medicine)
                            : markMedicineTaken(medicine);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: outOfStock
                        ? Colors.grey.withOpacity(0.2)
                        : taken
                            ? greencolor.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                    border: Border.all(
                      color: outOfStock
                          ? Colors.grey
                          : taken
                              ? greencolor
                              : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    outOfStock
                        ? "Out of stock"
                        : taken
                            ? "Taken"
                            : "Mark",
                    style: TextStyle(
                      color: outOfStock
                          ? Colors.grey
                          : taken
                              ? greencolor
                              : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Medicine info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.medicineName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: greencolor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qty: ${medicine.dosage} ${medicine.medicineUnit}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: $stock',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: outOfStock ? Colors.redAccent : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bottomView() {
    return Container(
      width: width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: filteredMedicines.map((medicine) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  medicineDetailsView(medicine),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            topView(),
            bottomView(),
          ],
        ),
      ),
    );
  }
}
