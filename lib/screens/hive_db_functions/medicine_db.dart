import 'package:hive/hive.dart';
import 'package:medicine_try1/model/medicine_model.dart';

const addMed_db = "medicine-database";

abstract class MedicineDbFunctions {
  Future<void> addMedicienDetails(Medicine values);
  Future<List<Medicine>> getMedicine();
  Future<void> deleteMedicine(String medid);
  Future<void> updateMedicine(Medicine updated);
  Future<List<Medicine>> getMedicineForDate(DateTime date);
}

class MedicineDb implements MedicineDbFunctions {
  @override
  Future<void> addMedicienDetails(Medicine values) async {
    final addMedDb = await Hive.openBox<Medicine>(addMed_db);
    addMedDb.put(values.id, values);
  }

  @override
  Future<void> deleteMedicine(String medid) async {
    final addMedDb = await Hive.openBox<Medicine>(addMed_db);
    await addMedDb.delete(medid);
  }

  @override
  Future<List<Medicine>> getMedicine() async {
    final addMedDb = await Hive.openBox<Medicine>(addMed_db);
    return addMedDb.values.toList();
  }

  @override
  Future<void> updateMedicine(Medicine updated) async {
    final addMedDb = await Hive.openBox<Medicine>(addMed_db);
    await addMedDb.put(updated.id, updated); // Replace existing record
  }

  @override
  Future<List<Medicine>> getMedicineForDate(DateTime date) async {
    final addMedDb = await Hive.openBox<Medicine>(addMed_db);
    final List<Medicine> allMedications = addMedDb.values.toList();
    final List<Medicine> medicationsForDate = allMedications.where((med) {
      // Adjust the comparison as per your date storage format in Medicine model
      return med.selectedDate ==
          date.toString(); // Example: Compare with selectedDate field
    }).toList();
    return medicationsForDate;
  }
}
