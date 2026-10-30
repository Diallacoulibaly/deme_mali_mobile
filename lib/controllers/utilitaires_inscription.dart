// Transforme une exception d'inscription en message lisible pour l'utilisateur
String messageErreurInscription(Object e) {
  final message = e.toString().replaceFirst('Exception: ', '').trim();

  if (message.contains('ClientException') ||
      message.contains('SocketException') ||
      message.contains('XMLHttpRequest')) {
    return 'Impossible de contacter le serveur. Vérifiez votre connexion.';
  }

  final minuscules = message.toLowerCase();
  if (minuscules.contains('existe déjà') ||
      minuscules.contains('existe deja') ||
      minuscules.contains('déjà utilisé') ||
      minuscules.contains('deja utilise') ||
      minuscules.contains('duplicata') ||
      minuscules.contains('duplicate') ||
      minuscules.contains('integrityconstraint') ||
      minuscules.contains('uk6wo7b684svg7hmrpxnkbf4uun')) {
    return 'Ce numéro de téléphone est déjà associé à un autre compte.';
  }

  if (message.contains('500') || minuscules.contains('internal server error')) {
    return 'Erreur (500) : Ce numéro de téléphone est probablement déjà utilisé par un compte existant.';
  }

  if (message.contains('400') || minuscules.contains('bad request')) {
    return 'Données invalides (400) : $message';
  }

  if (message.startsWith('Erreur HTTP')) {
    return message;
  }

  return message.isEmpty ? "Erreur lors de l'inscription." : message;
}

// Supprime les espaces du numéro pour avoir un format unique en base
String normaliserTelephone(String telephone) {
  return telephone.replaceAll(RegExp(r'\s+'), '');
}
