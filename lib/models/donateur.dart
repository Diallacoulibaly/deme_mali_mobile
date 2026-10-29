
class Donateur {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String? sexe;
  final int? paysId;
  final String? paysNom;

  const Donateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    this.sexe,
    this.paysId,
    this.paysNom,
  });

  factory Donateur.fromJson(Map<String, dynamic> json) {
    return Donateur(
      id: (json['id'] as num).toInt(),
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      sexe: json['sexe']?.toString(),
      paysId: json['paysId'] == null
          ? null
          : (json['paysId'] as num).toInt(),
      paysNom: json['paysNom']?.toString(),
    );
  }

  String get nomComplet => '$prenom $nom'.trim();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'sexe': sexe,
      'paysId': paysId,
      'paysNom': paysNom,
    };
  }
}
