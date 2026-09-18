// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TestResultAdapter extends TypeAdapter<TestResult> {
  @override
  final int typeId = 1;

  @override
  TestResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestResult(
      id: fields[0] as String,
      cropName: fields[1] as String,
      referenceBiomass: fields[2] as double,
      referenceNitrogen: fields[3] as double,
      predictedBiomass: fields[4] as double,
      predictedNitrogen: fields[5] as double,
      timestamp: fields[6] as DateTime,
      imagePath: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TestResult obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cropName)
      ..writeByte(2)
      ..write(obj.referenceBiomass)
      ..writeByte(3)
      ..write(obj.referenceNitrogen)
      ..writeByte(4)
      ..write(obj.predictedBiomass)
      ..writeByte(5)
      ..write(obj.predictedNitrogen)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
