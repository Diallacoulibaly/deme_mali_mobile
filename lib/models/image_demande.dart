
class ImageDemande {
  final int id;
  final String nomFichier;
  final String cheminFichier;
  final int demandeAideId;

  const ImageDemande({
    required this.id,
    required this.nomFichier,
    required this.cheminFichier,
    required this.demandeAideId,
  });

  factory ImageDemande.fromJson(Map<String, dynamic> json) {
    return ImageDemande(
      id: (json['id'] as num).toInt(),
      nomFichier: json['nomFichier'] ?? '',
      cheminFichier: json['cheminFichier'] ?? '',
      demandeAideId: (json['demandeAideId'] as num).toInt(),
    );
  }
}
