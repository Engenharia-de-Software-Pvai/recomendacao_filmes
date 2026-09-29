import 'package:recomendacao_filme/config/api_config.dart';

class Filme {
  final int id;
  final String titulo;
  final String sinopse;
  final String? posterPath;
  final double notaMedia;
  final String? dataLancamento;
  final List<int> generos;

  const Filme({
    required this.id,
    required this.titulo,
    required this.sinopse,
    this.posterPath,
    this.notaMedia = 0,
    this.dataLancamento,
    this.generos = const [],
  });

  factory Filme.fromTmdb(Map<String, dynamic> json) {
    // Listas trazem "genre_ids"; a tela de detalhes traz "genres": [{id, name}]
    final ids = json['genre_ids'] as List?;
    final objetos = json['genres'] as List?;
    final generos = ids != null
        ? ids.map((e) => e as int).toList()
        : (objetos ?? []).map((e) => (e as Map)['id'] as int).toList();

    return Filme(
      id: json['id'] as int,
      titulo: (json['title'] ?? '') as String,
      sinopse: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      notaMedia: (json['vote_average'] as num?)?.toDouble() ?? 0,
      dataLancamento: json['release_date'] as String?,
      generos: generos,
    );
  }

  String? get posterUrl => ApiConfig.urlPoster(posterPath);

  String get ano {
    final data = dataLancamento;
    return (data != null && data.length >= 4) ? data.substring(0, 4) : '—';
  }
}
