class BadgeDonateurModel {
  final int id;
  final String code;
  final String nom;
  final String? imageUrl;
  final double montantMinimum;
  final bool obtenu;
  final String? semestre;
  final int? annee;

  const BadgeDonateurModel({required this.id, required this.code, required this.nom,
    this.imageUrl, required this.montantMinimum, required this.obtenu,
    this.semestre, this.annee});

  factory BadgeDonateurModel.fromJson(Map<String, dynamic> json) => BadgeDonateurModel(
    id: _int(json['id']), code: '${json['code'] ?? ''}', nom: '${json['nom'] ?? 'Badge'}',
    imageUrl: (json['imageUrl'] ?? json['image_url']) as String?,
    montantMinimum: _double(json['montantMinimum'] ?? json['montant_minimum']),
    obtenu: json['obtenu'] == true,
    semestre: json['semestre'] as String?,
    annee: json['annee'] == null ? null : _int(json['annee']),
  );
  static int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  static double _double(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
}
