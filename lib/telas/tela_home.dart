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
  backgroundColor: Colors.transparent, // Torna o fundo padrão transparente
  elevation: 0, // Opcional: remove a sombra
  foregroundColor: cores.onPrimary,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cores.tertiary,
          cores.primary, 
        ],
      ),
    ),
  ),
  actions: [
    IconButton(
      tooltip: 'Sair',
      icon: Icon(Icons.logout, color: cores.onSecondary),
      onPressed: () => AuthService().sair(),
    ),
  ],
),
      body: _corpo(),
      bottomNavigationBar: Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        cores.tertiary,
          cores.primary, 
      ],
    ),
  ),
  child: NavigationBarTheme(
    data: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.all(
        TextStyle(color: cores.onPrimary),
      ),
      // Torna o fundo do tema transparente para o Container aparecer
      backgroundColor: Colors.transparent,
    ),
    child: NavigationBar(
      backgroundColor: Colors.transparent, // Fundo transparente
      indicatorColor: cores.surface.withValues(alpha: 0.3), // Opcional: cor do balão de seleção
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
),
    );
  }
}
