import 'package:recomendacao_filme/model/filme.dart';
import 'package:recomendacao_filme/service/filme_usuario_service.dart';
import 'package:recomendacao_filme/service/tmdb_service.dart';


class RecomendacaoService {
  final TmdbService _tmdb;
  final FilmeUsuarioService _usuario;

  RecomendacaoService({TmdbService? tmdb, FilmeUsuarioService? usuario})
      : _tmdb = tmdb ?? TmdbService(),
        _usuario = usuario ?? FilmeUsuarioService();

  Future<({List<Filme> filmes, bool personalizada})> gerar() async {
    final salvos = await _usuario.listar();
    final jaVistos = salvos.map((f) => f.filmeId).toSet();

    final sementes = salvos
        .where((f) => f.favorito || (f.nota ?? 0) >= 4)
        .take(5)
        .toList();

    if (sementes.isEmpty) {
      final populares = await _tmdb.populares();
      return (
        filmes: populares.where((f) => !jaVistos.contains(f.id)).toList(),
        personalizada: false,
      );
    }

    final listas = await Future.wait(
      sementes.map((s) => _tmdb.recomendadosPara(s.filmeId)),
    );

    final pontos = <int, double>{};
    final porId = <int, Filme>{};
    for (final lista in listas) {
      for (final filme in lista) {
        if (jaVistos.contains(filme.id)) continue;
        porId[filme.id] = filme;
        pontos[filme.id] = (pontos[filme.id] ?? 0) + 1 + filme.notaMedia / 10;
      }
    }

    final ordenados = porId.values.toList()
      ..sort((a, b) => pontos[b.id]!.compareTo(pontos[a.id]!));

    return (filmes: ordenados.take(30).toList(), personalizada: true);
  }
}
