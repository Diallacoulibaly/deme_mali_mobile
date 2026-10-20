class DemandeAide {
  final int id;
  final String titre;
  final String descriptionSituation;
  final String niveauUrgence;
  final String statut;
  final DateTime? dateCreation;
  final String? motif;
  final int? nombrePersonne;
  final double? montantNecessaire;
  final double? montantCollecte;
  final String? statutCollecte;
  final int? beneficiaireId;
  final String? beneficiaireNom;
  final String? beneficiairePrenom;
  final int? categorieDemandeId;
  final String? categorieDemandeNom;
  final String? typeDemande;
  final String? typeDemandeAide;

  const DemandeAide({
    required this.id, required this.titre, required this.descriptionSituation,
    required this.niveauUrgence, required this.statut, this.dateCreation,
    this.motif, this.nombrePersonne, this.montantNecessaire, this.montantCollecte,
    this.statutCollecte, this.beneficiaireId, this.beneficiaireNom,
    this.beneficiairePrenom, this.categorieDemandeId, this.categorieDemandeNom,
    this.typeDemande, this.typeDemandeAide,
  });

  factory DemandeAide.fromJson(Map<String, dynamic> json) {
    DateTime? date(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
    int? integer(dynamic v) => v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));
    double? decimal(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));
    return DemandeAide(
      id: integer(json['id']) ?? 0,
      titre: (json['titre'] ?? '').toString(),
      descriptionSituation: (json['descriptionSituation'] ?? '').toString(),
      niveauUrgence: (json['niveauUrgence'] ?? '').toString(),
      statut: (json['statut'] ?? '').toString(),
      dateCreation: date(json['dateCreation']),
      motif: json['motif']?.toString(),
      nombrePersonne: integer(json['nombrePersonne']),
      montantNecessaire: decimal(json['montantNecessaire']),
      montantCollecte: decimal(json['montantCollecte']),
      statutCollecte: json['statutCollecte']?.toString(),
      beneficiaireId: integer(json['beneficiaireId']),
      beneficiaireNom: json['beneficiaireNom']?.toString(),
      beneficiairePrenom: json['beneficiairePrenom']?.toString(),
      categorieDemandeId: integer(json['categorieDemandeId']),
      categorieDemandeNom: json['categorieDemandeNom']?.toString(),
      typeDemande: json['typeDemande']?.toString(),
      typeDemandeAide: json['typeDemandeAide']?.toString(),
    );
  }
}
