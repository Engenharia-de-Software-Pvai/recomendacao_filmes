import 'dart:convert';

import 'package:recomendacao_filme/config/api_config.dart';
import 'package:recomendacao_filme/model/filme.dart';
import 'package:http/http.dart' as http;

/// API externa: The Movie Database (https://developer.themoviedb.org).
class TmdbService {
  static const _host = 'api.themoviedb.org';
  static const _prazo = Duration(seconds: 15);
  static const _headers = {'Accept': 'application/json'};

  Uri _uri(String caminho, [Map<String, String>? extras]) {
    return Uri.https(_host, '/3$caminho', {
      'api_key': ApiConfig.tmdbApiKey,
      'language': 'pt-BR',
      ...?extras,
    });
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    if (ApiConfig.tmdbApiKey.isEmpty) {
      throw Exception('Chave do TMDB ausente (use --dart-define=TMDB_API_KEY=...)');
    }
    final resposta = await http.get(uri, headers: _headers).timeout(_prazo);
    if (resposta.statusCode != 200) {
      throw Exception('TMDB: HTTP ${resposta.statusCode}');
    }
    return jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
  }

  List<Filme> _lista(Map<String, dynamic> json) {
    return (json['results'] as List)
        .map((e) => Filme.fromTmdb(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Filme>> populares() async =>
      _lista(await _get(_uri('/movie/popular')));

  Future<List<Filme>> buscar(String termo) async =>
      _lista(await _get(_uri('/search/movie', {'query': termo})));

  Future<Filme> detalhes(int id) async =>
      Filme.fromTmdb(await _get(_uri('/movie/$id')));

  /// Filmes semelhantes a um filme específico (base da recomendação).
  Future<List<Filme>> recomendadosPara(int id) async =>
      _lista(await _get(_uri('/movie/$id/recommendations')));
}
