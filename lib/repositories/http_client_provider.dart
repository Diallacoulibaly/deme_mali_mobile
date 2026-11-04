import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'auth_repository.dart';

class ClientAuthentifie extends http.BaseClient {
  final http.Client _interne;
  final Future<String?> Function() _lireToken;

  ClientAuthentifie(this._interne, this._lireToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _lireToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return _interne.send(request);
  }

  @override
  void close() => _interne.close();
}

final httpClientProvider = Provider<http.Client>((ref) {
  final client = ClientAuthentifie(
    http.Client(),
    AuthRepository().recupererToken,
  );
  ref.onDispose(client.close);
  return client;
});