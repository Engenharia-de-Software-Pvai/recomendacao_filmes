import 'package:recomendacao_filme/model/filme.dart';
import 'package:recomendacao_filme/model/filme_usuario.dart';
import 'package:recomendacao_filme/service/filme_usuario_service.dart';
import 'package:recomendacao_filme/service/tmdb_service.dart';
import 'package:recomendacao_filme/widgets/filme_widgets.dart';
import 'package:flutter/material.dart';
import 'package:recomendacao_filme/style/colorScheme.dart' as custom_colors;

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
    final cores = custom_colors.colorScheme;
    final filme = _filme;
    return Scaffold(
      backgroundColor: cores.surface,
      appBar: AppBar(
        title: Text(filme?.titulo ?? 'Filme'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      ),
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
                Card(
                  color: cores.surfaceContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filme.titulo,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: cores.primary,
                          ),
                        ),
                        Text(
                          '${filme.ano} · TMDB ${filme.notaMedia.toStringAsFixed(1)}',
                          style: TextStyle(color: cores.secondary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          filme.sinopse.isEmpty
                              ? 'Sem sinopse disponível.'
                              : filme.sinopse,
                          style: TextStyle(color: cores.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sua avaliação',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cores.tertiary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Linha das Estrelas
                      Row(
                        children: [
                          for (var n = 1; n <= 5; n++)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                visualDensity: VisualDensity.compact,
                                onPressed: () => _salvar(nota: n),
                                icon: Icon(
                                  (_usuario?.nota ?? 0) >= n
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: cores.secondary,
                                  size: 28,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Botões
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              backgroundColor: cores.primary,
                              foregroundColor: cores.onPrimary,
                            ),
                            onPressed: () =>
                                _salvar(favorito: !(_usuario?.favorito ?? false)),
                            icon: Icon(
                              (_usuario?.favorito ?? false)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            label: Text(
                              (_usuario?.favorito ?? false)
                                  ? 'Favoritado'
                                  : 'Favoritar',
                            ),
                          ),
                          if (_usuario != null)
                            TextButton(
                              onPressed: _remover,
                              child: Text(
                                'Remover da lista',
                                style: TextStyle(color: cores.onSurfaceVariant),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else if (!_ocupado && _erro != null)
                OutlinedButton(
                  onPressed: _carregar,
                  child: const Text('Tentar novamente'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}