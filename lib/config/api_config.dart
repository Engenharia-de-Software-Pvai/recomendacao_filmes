class ApiConfig {
  static const tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');

  static const _imagemBase = 'https://image.tmdb.org/t/p/w342';

  static String? urlPoster(String? caminho) =>
      caminho == null ? null : '$_imagemBase$caminho';
}
