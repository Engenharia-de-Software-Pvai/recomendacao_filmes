import 'package:cloud_firestore/cloud_firestore.dart';

/// Filme salvo pelo usuário no Firestore (nota e/ou favorito).
/// Caminho: usuarios/{uid}/filmes/{filmeId}
class FilmeUsuario {
  final int filmeId;
  final String titulo;
  final String? posterPath;
  final int? nota; // 1 a 5
  final bool favorito;

  const FilmeUsuario({
    required this.filmeId,
    required this.titulo,
    this.posterPath,
    this.nota,
    this.favorito = false,
  });

  factory FilmeUsuario.fromMap(String id, Map<String, dynamic> map) {
    return FilmeUsuario(
      filmeId: int.parse(id),
      titulo: map['titulo'] as String,
      posterPath: map['posterPath'] as String?,
      nota: map['nota'] as int?,
      favorito: (map['favorito'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'posterPath': posterPath,
      'nota': nota,
      'favorito': favorito,
      'atualizadoEm': FieldValue.serverTimestamp(),
    };
  }
}
