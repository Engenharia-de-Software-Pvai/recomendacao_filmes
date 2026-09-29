import 'package:recomendacao_filme/model/filme_usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Cloud Firestore: filmes avaliados/favoritados pelo usuário logado.
class FilmeUsuarioService {
  CollectionReference<Map<String, dynamic>> get _colecao {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Usuário não autenticado');
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('filmes');
  }

  List<FilmeUsuario> _converter(QuerySnapshot<Map<String, dynamic>> snap) {
    return snap.docs.map((d) => FilmeUsuario.fromMap(d.id, d.data())).toList();
  }

  /// Atualiza em tempo real a lista "Minha lista".
  Stream<List<FilmeUsuario>> observar() =>
      _colecao.orderBy('atualizadoEm', descending: true).snapshots().map(_converter);

  Future<List<FilmeUsuario>> listar() async =>
      _converter(await _colecao.orderBy('atualizadoEm', descending: true).get());

  Future<FilmeUsuario?> buscar(int filmeId) async {
    final doc = await _colecao.doc('$filmeId').get();
    final dados = doc.data();
    return dados == null ? null : FilmeUsuario.fromMap(doc.id, dados);
  }

  Future<void> salvar(FilmeUsuario filme) =>
      _colecao.doc('${filme.filmeId}').set(filme.toMap(), SetOptions(merge: true));

  Future<void> remover(int filmeId) => _colecao.doc('$filmeId').delete();
}
