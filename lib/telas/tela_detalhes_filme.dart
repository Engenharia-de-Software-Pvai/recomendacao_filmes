import 'package:recomendacao_filme/model/filme.dart';
import 'package:recomendacao_filme/model/filme_usuario.dart';
import 'package:recomendacao_filme/service/filme_usuario_service.dart';
import 'package:recomendacao_filme/service/tmdb_service.dart';
import 'package:recomendacao_filme/widgets/filme_widgets.dart';
import 'package:flutter/material.dart';

class TelaDetalhesFilme extends StatefulWidget {
  final int filmeId;

  const TelaDetalhesFilme({super.key, required this.filmeId});

  @override
  State<TelaDetalhesFilme> createState() => _TelaDetalhesFilmeState();
}

class _TelaDetalhesFilmeState extends State<TelaDetalhesFilme> {
  final _tmdb = TmdbService();
  final _usuarioService = FilmeUsuarioService();

  Filme? _filme; // vem da API (TMDB)
  FilmeUsuario? _usuario; // vem do Firestore
  bool _ocupado = true;
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
      final resultados = await Future.wait([
        _tmdb.detalhes(widget.filmeId),
        _usuarioService.buscar(widget.filmeId),
      ]);
      if (mounted) {
        setState(() {
          _filme = resultados[0] as Filme;
          _usuario = resultados[1] as FilmeUsuario?;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _erro = 'Erro ao carregar o filme.\n$e');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _salvar({int? nota, bool? favorito}) async {
    final filme = _filme;
    if (filme == null) return;
    final novo = FilmeUsuario(
      filmeId: filme.id,
      titulo: filme.titulo,
      posterPath: filme.posterPath,
      nota: nota ?? _usuario?.nota,
      favorito: favorito ?? _usuario?.favorito ?? false,
    );
    setState(() => _ocupado = true);
    try {
      await _usuarioService.salvar(novo);
      if (mounted) setState(() => _usuario = novo);
    } catch (e) {
      if (mounted) setState(() => _erro = 'Erro ao salvar.\n$e');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _remover() async {
    setState(() => _ocupado = true);
    try {
      await _usuarioService.remover(widget.filmeId);
      if (mounted) setState(() => _usuario = null);
    } catch (e) {
      if (mounted) setState(() => _erro = 'Erro ao remover.\n$e');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filme = _filme;
    return Scaffold(
      appBar: AppBar(title: Text(filme?.titulo ?? 'Filme')),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _ocupado,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_ocupado) const LinearProgressIndicator(),
              if (_erro != null)
                Text(_erro!, style: const TextStyle(color: Colors.red)),
              if (filme != null) ...[
                Center(
                  child: SizedBox(
                    width: 220,
                    child: Poster(url: filme.posterUrl, altura: 320),
                  ),
                ),
                const SizedBox(height: 16),
                Text(filme.titulo, style: Theme.of(context).textTheme.headlineSmall),
                Text('${filme.ano} · TMDB ${filme.notaMedia.toStringAsFixed(1)}'),
                const SizedBox(height: 12),
                Text(filme.sinopse.isEmpty ? 'Sem sinopse disponível.' : filme.sinopse),
                const Divider(height: 32),
                const Text('Sua avaliação'),
                Row(
                  children: [
                    for (var n = 1; n <= 5; n++)
                      IconButton(
                        onPressed: () => _salvar(nota: n),
                        icon: Icon(
                          (_usuario?.nota ?? 0) >= n ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                      ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _salvar(favorito: !(_usuario?.favorito ?? false)),
                      icon: Icon((_usuario?.favorito ?? false)
                          ? Icons.favorite
                          : Icons.favorite_border),
                      label: Text((_usuario?.favorito ?? false)
                          ? 'Favoritado'
                          : 'Favoritar'),
                    ),
                    if (_usuario != null)
                      TextButton(onPressed: _remover, child: const Text('Remover da lista')),
                  ],
                ),
              ] else if (!_ocupado && _erro != null)
                OutlinedButton(onPressed: _carregar, child: const Text('Tentar novamente')),
            ],
          ),
        ),
      ),
    );
  }
}
