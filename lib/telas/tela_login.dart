import 'package:recomendacao_filme/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _form = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _auth = AuthService();

  bool _cadastro = false;
  bool _ocupado = false;
  String? _erro;

  String? _obrigatorio(String? texto) =>
      (texto == null || texto.trim().isEmpty) ? 'Campo obrigatório' : null;

  Future<void> _enviar() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _ocupado = true;
      _erro = null;
    });
    try {
      final email = _emailController.text.trim();
      final senha = _senhaController.text;
      if (_cadastro) {
        await _auth.cadastrar(email, senha);
      } else {
        await _auth.entrar(email, senha);
      }
      // Sucesso: o PortaoAuth troca de tela sozinho
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _erro = AuthService.traduzirErro(e));
    } catch (_) {
      if (mounted) setState(() => _erro = 'Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.movie_filter, size: 72),
                    const SizedBox(height: 8),
                    Text('Recomenda Filmes',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      validator: _obrigatorio,
                    ),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      validator: _obrigatorio,
                    ),
                    const SizedBox(height: 16),
                    if (_erro != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(_erro!, style: const TextStyle(color: Colors.red)),
                      ),
                    if (_ocupado) const LinearProgressIndicator(),
                    FilledButton(
                      onPressed: _ocupado ? null : _enviar,
                      child: Text(_cadastro ? 'Criar conta' : 'Entrar'),
                    ),
                    TextButton(
                      onPressed: _ocupado
                          ? null
                          : () => setState(() {
                                _cadastro = !_cadastro;
                                _erro = null;
                              }),
                      child: Text(_cadastro
                          ? 'Já tenho conta'
                          : 'Não tenho conta, quero me cadastrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
