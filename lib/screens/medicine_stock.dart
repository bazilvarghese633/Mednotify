// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:medicine_try1/model/medicine_model.dart';

// class MedicineStockScreen extends StatelessWidget {
//   const MedicineStockScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final medicineBox = Hive.box<Medicine>('medicine-database');

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 227, 226, 226),
//         title: const Center(
//           child: Text(
//             "Medicine Stock          ",
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: medicineBox.listenable(),
//         builder: (context, Box<Medicine> box, _) {
//           if (box.isEmpty) {
//             return const Center(
//               child: Text(
//                 "No medicines added",
//                 style: TextStyle(fontSize: 16),
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: box.length,
//             itemBuilder: (context, index) {
//               final medicine = box.getAt(index);

//               if (medicine == null) return const SizedBox();

//               final medicineName = medicine.medicineName;
//               final stock = medicine.currentstock;

//               return Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     width: 2,
//                     color: stock == 0 ? Colors.red : Colors.green,
//                   ),
//                   color: Colors.white,
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.medication,
//                       size: 35,
//                       color: stock == 0 ? Colors.red : Colors.green,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             medicineName,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             stock == 0 ? "Out of Stock" : "Stock: $stock",
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               color: stock == 0 ? Colors.red : Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:medicine_try1/local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationDemoScreen extends StatelessWidget {
  const NotificationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                LocalNotificationService().showNotification(
                  'Instant Notification',
                  'This is an instant notification!',
                );
              },
              child: const Text('Show Instant Notification'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final scheduledTime =
                    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

                LocalNotificationService().scheduleNotification(
                  id: 1,
                  title: 'Scheduled Notification',
                  body: 'This will appear in 5 seconds',
                  scheduledDate: scheduledTime,
                );
              },
              child: const Text('Schedule Notification in 5 seconds'),
            ),
          ],
        ),
      ),
    );
  }
}
