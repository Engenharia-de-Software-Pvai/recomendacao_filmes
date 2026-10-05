import 'package:recomendacao_filme/service/auth_service.dart';
import 'package:recomendacao_filme/telas/tela_descobrir.dart';
import 'package:recomendacao_filme/telas/tela_minha_lista.dart';
import 'package:recomendacao_filme/telas/tela_recomendacoes.dart';
import 'package:flutter/material.dart';
import 'package:recomendacao_filme/style/colorScheme.dart' as custom_colors;

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  int _indice = 0;

   final cores = custom_colors.colorScheme;

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
      backgroundColor: cores.surface,
      appBar: AppBar(
        title: Text(_titulos[_indice]),
        backgroundColor: cores.primary,
        foregroundColor: cores.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: Icon(Icons.logout, color: cores.onSecondary),
            onPressed: () => AuthService().sair(),
          ),
        ],
      ),
      body: _corpo(),
      bottomNavigationBar: NavigationBarTheme(
  data: NavigationBarThemeData(
    labelTextStyle: WidgetStateProperty.all(
      TextStyle(color: cores.onPrimary),
    ),
    backgroundColor: cores.primary,
  ),
  child: NavigationBar(
    selectedIndex: _indice,
    onDestinationSelected: (i) => setState(() => _indice = i),
    destinations: [
      NavigationDestination(
        icon: Icon(Icons.explore, color: cores.onPrimary),
        label: 'Descobrir',
      ),
      NavigationDestination(
        icon: Icon(Icons.auto_awesome, color: cores.onPrimary),
        label: 'Para você',
      ),
      NavigationDestination(
        icon: Icon(Icons.bookmark, color: cores.onPrimary),
        label: 'Minha lista',
      ),
    ],
  ),
),
    );
  }
}
