// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppointmentAdapter extends TypeAdapter<Appointment> {
  @override
  final int typeId = 0;

  @override
  Appointment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appointment(
      doctorName: fields[0] as String,
      hospitalName: fields[1] as String,
      appointmentDate: fields[2] as DateTime,
      appointmentTime: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Appointment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.doctorName)
      ..writeByte(1)
      ..write(obj.hospitalName)
      ..writeByte(2)
      ..write(obj.appointmentDate)
      ..writeByte(3)
      ..write(obj.appointmentTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
