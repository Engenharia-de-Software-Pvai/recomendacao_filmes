import 'package:recomendacao_filme/service/auth_service.dart';
import 'package:recomendacao_filme/telas/tela_descobrir.dart';
import 'package:recomendacao_filme/telas/tela_minha_lista.dart';
import 'package:recomendacao_filme/telas/tela_recomendacoes.dart';
import 'package:flutter/material.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  int _indice = 0;

  static const _titulos = ['Descobrir', 'Para você', 'Minha lista'];

  // As telas são recriadas ao trocar de aba, então as recomendações
  // sempre refletem as últimas notas do usuário.
  Widget _corpo() {
    switch (_indice) {
      case 0:
        return const TelaDescobrir();
      case 1:
        return const TelaRecomendacoes();
      default:
        return const TelaMinhaLista();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_indice]),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().sair(),
          ),
        ],
      ),
      body: _corpo(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore), label: 'Descobrir'),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Para você'),
          NavigationDestination(icon: Icon(Icons.bookmark), label: 'Minha lista'),
        ],
      ),
    );
  }
}
