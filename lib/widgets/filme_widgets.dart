import 'package:recomendacao_filme/model/filme.dart';
import 'package:flutter/material.dart';

class Poster extends StatelessWidget {
  final String? url;
  final double? altura;

  const Poster({super.key, this.url, this.altura});

  @override
  Widget build(BuildContext context) {
    final vazio = Container(
      height: altura,
      color: Colors.black12,
      alignment: Alignment.center,
      child: const Icon(Icons.movie_outlined, size: 40),
    );
    if (url == null) return vazio;
    return Image.network(
      url!,
      height: altura,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => vazio,
    );
  }
}

class GradeFilmes extends StatelessWidget {
  final List<Filme> filmes;
  final void Function(Filme) aoTocar;

  const GradeFilmes({super.key, required this.filmes, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filmes.length,
      itemBuilder: (context, i) {
        final filme = filmes[i];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => aoTocar(filme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Poster(url: filme.posterUrl)),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filme.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${filme.notaMedia.toStringAsFixed(1)} · ${filme.ano}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
