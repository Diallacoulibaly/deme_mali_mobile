class Beneficiaire {
  final int id;
  final String nom;
  final String prenom;
  final String? ville;
  final String? adresse;
  final String? statut;

  const Beneficiaire({required this.id, required this.nom, required this.prenom,
    this.ville, this.adresse, this.statut});

  factory Beneficiaire.fromJson(Map<String, dynamic> json) => Beneficiaire(
    id: (json['id'] as num?)?.toInt() ?? 0,
    nom: (json['nom'] ?? '').toString(),
    prenom: (json['prenom'] ?? '').toString(),
    ville: json['ville']?.toString(),
    adresse: json['adresse']?.toString(),
    statut: json['statut']?.toString(),
  );
}
