// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Urun.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UrunAdapter extends TypeAdapter<Urun> {
  @override
  final int typeId = 0;

  @override
  Urun read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Urun(
      isim: fields[0] as String,
      miktar: fields[1] as double,
      miktarTuru: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Urun obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.isim)
      ..writeByte(1)
      ..write(obj.miktar)
      ..writeByte(2)
      ..write(obj.miktarTuru);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrunAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
