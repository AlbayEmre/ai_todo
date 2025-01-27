import 'package:hive/hive.dart';

part 'Urun.g.dart';

@HiveType(typeId: 0)
class Urun extends HiveObject {
  @HiveField(0)
  String isim;

  @HiveField(1)
  double miktar;

  @HiveField(2)
  String miktarTuru;

  Urun({required this.isim, required this.miktar, required this.miktarTuru});

  factory Urun.fromMap(Map<String, dynamic> map) {
    return Urun(
      isim: map['isim'] ?? '',
      miktar: map['miktar']?.toDouble() ?? 0.0,
      miktarTuru: map['miktarTuru'] ?? '',
    );
  }
}
