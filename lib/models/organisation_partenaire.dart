
class OrganisationPartenaire {
  final int id;
  final String? nom;
  final String? prenom;
  final String? telephone;
  final String? role;

  final String? nif;
  final String? adresse;
  final String nomOrganisation;
  final String typeOrganisation;
  final String ville;
  final String? documentJustificatif;
  final String? dateInscription;
  final String? statutValidation;
  final String? dateValidation;
  final String? email;
  final String? telephoneOrganisation;
  final int nombreLikes;
  final bool aimeParMoi;

  OrganisationPartenaire({
    required this.id,
    this.nom,
    this.prenom,
    this.telephone,
    this.role,
   required this.nomOrganisation,
    required this.typeOrganisation,
    this.nif,
    this.adresse,
    required this.ville,
    this.documentJustificatif,
    this.dateInscription,
    this.statutValidation,
    this.dateValidation,
    this.email,
    this.telephoneOrganisation,
    this.nombreLikes = 0,
    this.aimeParMoi = false,
  });

  factory OrganisationPartenaire.fromJson(
      Map<String, dynamic> json,
      ) {
    return OrganisationPartenaire(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      telephone: json['telephone'] as String?,
      role: json['role']?.toString(),
      nomOrganisation: json['nomOrganisation'] as String,
      typeOrganisation: json['typeOrganisation'] as String,
      nif: json['nif'] as String?,
      adresse: json['adresse'] as String?,
      ville: json['ville'] as String,
      documentJustificatif:
      json['documentJustificatif'] as String?,
      dateInscription: json['dateInscription']?.toString(),
      statutValidation: json['statutValidation']?.toString(),
      dateValidation: json['dateValidation']?.toString(),
      email: json['email'] as String?,
      telephoneOrganisation:
      json['telephoneOrganisation'] as String?,
      nombreLikes:
      (json['nombreLikes'] as num?)?.toInt() ?? 0,
      aimeParMoi: json['aimeParMoi'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'role': role,
      'nomOrganisation': nomOrganisation,
      'typeOrganisation': typeOrganisation,
      'nif': nif,
      'adresse': adresse,
      'ville': ville,
      'documentJustificatif': documentJustificatif,
      'dateInscription': dateInscription,
      'statutValidation': statutValidation,
      'dateValidation': dateValidation,
      'email': email,
      'telephoneOrganisation': telephoneOrganisation,
      'nombreLikes': nombreLikes,
      'aimeParMoi': aimeParMoi,
    };
  }

  OrganisationPartenaire copyWith({
    int? nombreLikes,
    bool? aimeParMoi,
  }) {
    return OrganisationPartenaire(
      id: id,
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      role: role,
      nomOrganisation: nomOrganisation,
      typeOrganisation: typeOrganisation,
      nif: nif,
      adresse: adresse,
      ville: ville,
      documentJustificatif: documentJustificatif,
      dateInscription: dateInscription,
      statutValidation: statutValidation,
      dateValidation: dateValidation,
      email: email,
      telephoneOrganisation: telephoneOrganisation,
      nombreLikes: nombreLikes ?? this.nombreLikes,
      aimeParMoi: aimeParMoi ?? this.aimeParMoi,
    );
  }
}
