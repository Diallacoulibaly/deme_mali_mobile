class DemandeAide {
  final int id;
  final int nombreDonateurs;
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
    required this.id,
    this.nombreDonateurs = 0,
    required this.titre,
    required this.descriptionSituation,
    required this.niveauUrgence,
    required this.statut,
    this.dateCreation,
    this.motif,
    this.nombrePersonne,
    this.montantNecessaire,
    this.montantCollecte,
    this.statutCollecte,
    this.beneficiaireId,
    this.beneficiaireNom,
    this.beneficiairePrenom,
    this.categorieDemandeId,
    this.categorieDemandeNom,
    this.typeDemande,
    this.typeDemandeAide,
  });

  factory DemandeAide.fromJson(Map<String, dynamic> json) {
    DateTime? date(dynamic value) {
      return value == null
          ? null
          : DateTime.tryParse(value.toString());
    }

    int? integer(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? decimal(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return DemandeAide(
      id: integer(json['id']) ?? 0,
      nombreDonateurs: integer(json['nombreDonateurs']) ?? 0,
      titre: (json['titre'] ?? '').toString(),
      descriptionSituation:
      (json['descriptionSituation'] ?? '').toString(),
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

  bool get estFinanciere {
    final type = (typeDemandeAide ?? typeDemande ?? '').toUpperCase();
    return type == 'FINANCIERE';
  }

  bool get estMaterielle {
    final type = (typeDemandeAide ?? typeDemande ?? '').toUpperCase();
    return type == 'MATERIELLE';
  }
}