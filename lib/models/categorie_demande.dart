class CategorieDemande {
  final int id;
  final String nom;
  final String? description;

  const CategorieDemande({
    required this.id,
    required this.nom,
    this.description,
  });

  factory CategorieDemande.fromJson(Map<String, dynamic> json) {
    return CategorieDemande(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: (json['nom'] ?? json['libelle'] ?? json['titre'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      if (description != null) 'description': description,
    };
  }
}
