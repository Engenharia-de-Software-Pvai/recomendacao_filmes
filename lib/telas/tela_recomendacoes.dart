import 'package:recomendacao_filme/model/filme.dart';
import 'package:recomendacao_filme/service/recomendacao_service.dart';
import 'package:recomendacao_filme/telas/tela_detalhes_filme.dart';
import 'package:recomendacao_filme/widgets/filme_widgets.dart';
import 'package:flutter/material.dart';

class TelaRecomendacoes extends StatefulWidget {
  const TelaRecomendacoes({super.key});

  @override
  State<TelaRecomendacoes> createState() => _TelaRecomendacoesState();
}

class _TelaRecomendacoesState extends State<TelaRecomendacoes> {
  final _servico = RecomendacaoService();

  List<Filme> _filmes = [];
  bool _personalizada = false;
  bool _ocupado = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _ocupado = true;
      _erro = null;
    });
    try {
      final resultado = await _servico.gerar();
      if (mounted) {
        setState(() {
          _filmes = resultado.filmes;
          _personalizada = resultado.personalizada;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _erro = 'Não foi possível gerar recomendações.\n$e');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_ocupado) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _personalizada
                      ? 'Baseado nos filmes que você favoritou e avaliou bem'
                      : 'Avalie ou favorite filmes para receber recomendações personalizadas. Por enquanto, os mais populares:',
                ),
              ),
              IconButton(
                tooltip: 'Atualizar',
                icon: const Icon(Icons.refresh),
                onPressed: _ocupado ? null : _carregar,
              ),
            ],
          ),
        ),
        if (_erro != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_erro!, style: const TextStyle(color: Colors.red)),
          ),
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
