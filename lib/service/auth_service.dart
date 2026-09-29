import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication (e-mail e senha).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get usuarioStream => _auth.authStateChanges();

  User? get usuario => _auth.currentUser;

  Future<void> entrar(String email, String senha) =>
      _auth.signInWithEmailAndPassword(email: email, password: senha);

  Future<void> cadastrar(String email, String senha) =>
      _auth.createUserWithEmailAndPassword(email: email, password: senha);

  Future<void> sair() => _auth.signOut();

  static String traduzirErro(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Já existe uma conta com esse e-mail.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'Login por e-mail/senha não está ativado no Firebase Authentication.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Erro de autenticação (${e.code}).';
    }
  }
}
