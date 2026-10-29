class ArticleDemande {
  final int id;
  final String designation;
  final int quantiteDemandee;
  final String unite;
  final double prixUnitaireEstime;

  ArticleDemande({
    required this.id,
    required this.designation,
    required this.quantiteDemandee,
    required this.unite,
    required this.prixUnitaireEstime,
  });

  factory ArticleDemande.fromJson(Map<String, dynamic> json) {
    return ArticleDemande(
      id: (json['id'] as num?)?.toInt() ?? 0,
      designation: json['designation']?.toString() ?? '',
      quantiteDemandee: (json['quantiteDemandee'] as num?)?.toInt() ?? 0,
      unite: json['unite']?.toString() ?? '',
      prixUnitaireEstime: (json['prixUnitaireEstime'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
