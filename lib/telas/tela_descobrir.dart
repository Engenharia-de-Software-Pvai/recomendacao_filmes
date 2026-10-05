import 'package:recomendacao_filme/model/filme.dart';
import 'package:recomendacao_filme/service/tmdb_service.dart';
import 'package:recomendacao_filme/telas/tela_detalhes_filme.dart';
import 'package:recomendacao_filme/widgets/filme_widgets.dart';
import 'package:flutter/material.dart';
import 'package:recomendacao_filme/style/colorScheme.dart' as custom_colors;

class TelaDescobrir extends StatefulWidget {
  const TelaDescobrir({super.key});

  @override
  State<TelaDescobrir> createState() => _TelaDescobrirState();
}

class _TelaDescobrirState extends State<TelaDescobrir> {
  final cores = custom_colors.colorScheme;

  final _tmdb = TmdbService();
  final _buscaController = TextEditingController();

  List<Filme> _filmes = [];
  bool _ocupado = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final termo = _buscaController.text.trim();
    setState(() {
      _ocupado = true;
      _erro = null;
    });
    try {
      final filmes = termo.isEmpty ? await _tmdb.populares() : await _tmdb.buscar(termo);
      if (mounted) setState(() => _filmes = filmes);
    } catch (e) {
      if (mounted) setState(() => _erro = 'Não foi possível carregar os filmes.\n$e');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
  controller: _buscaController,
  textInputAction: TextInputAction.search,
  onSubmitted: (_) => _carregar(),
  style: TextStyle(color: cores.onSurface), // Cor do texto quando digita
  decoration: InputDecoration(
    hintText: 'Buscar filme...',
    hintStyle: TextStyle(color: cores.onSurfaceVariant), // Cor do texto "Buscar filme..."
    
    // 1. Cor de Fundo Interna
    filled: true,
    fillColor: cores.surfaceContainer, // Altere para a cor que desejar (ex: Colors.white)
    
    // 2. Cor dos Ícones
    prefixIcon: Icon(Icons.search, color: cores.onSurfaceVariant),
    suffixIcon: IconButton(
      icon: Icon(Icons.clear, color: cores.onSurfaceVariant),
      onPressed: () {
        _buscaController.clear();
        _carregar();
      },
    ),
    
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: cores.surfaceContainer),
    ),
    
    // 4. Cor da Borda ao Clicar/Focar
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: cores.primary, width: 2),
    ),
  ),
)
        ),
        if (_ocupado) const LinearProgressIndicator(),
        if (_erro != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_erro!, style: const TextStyle(color: Colors.red)),
          ),
        if (!_ocupado && _erro == null && _filmes.isEmpty)
          const Padding(padding: EdgeInsets.all(16), child: Text('Nenhum filme encontrado')),
        Expanded(
          child: GradeFilmes(
            filmes: _filmes,
            aoTocar: (f) => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TelaDetalhesFilme(filmeId: f.id)),
            ),
          ),
        ),
      ],
    );
  }
}
