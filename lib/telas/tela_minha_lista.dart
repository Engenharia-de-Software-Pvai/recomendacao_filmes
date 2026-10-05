import 'package:recomendacao_filme/config/api_config.dart';
import 'package:recomendacao_filme/model/filme_usuario.dart';
import 'package:recomendacao_filme/service/filme_usuario_service.dart';
import 'package:recomendacao_filme/telas/tela_detalhes_filme.dart';
import 'package:recomendacao_filme/widgets/filme_widgets.dart';
import 'package:flutter/material.dart';
import 'package:recomendacao_filme/style/colorScheme.dart' as custom_colors;


class TelaMinhaLista extends StatefulWidget {
  const TelaMinhaLista({super.key});

  @override
  State<TelaMinhaLista> createState() => _TelaMinhaListaState();
}

class _TelaMinhaListaState extends State<TelaMinhaLista> {
  // Criado uma única vez: se ficasse no build(), cada rebuild abriria uma nova escuta no Firestore
  late final Stream<List<FilmeUsuario>> _stream = FilmeUsuarioService().observar();

  @override
  Widget build(BuildContext context) {
       final cores = custom_colors.colorScheme;

    return StreamBuilder<List<FilmeUsuario>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(
            'Erro ao carregar: ${snapshot.error}',
             style: TextStyle(color: cores.error)
          ),);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final filmes = snapshot.data!;
        if (filmes.isEmpty) {
          return Center(child: Text('Você ainda não avaliou nenhum filme', style: TextStyle(color: cores.onSurfaceVariant),),);
        }
        return ListView.builder(
          itemCount: filmes.length,
          itemBuilder: (context, i) {
            final f = filmes[i];
            return ListTile(
              tileColor: cores.surfaceContainer,
              leading: SizedBox(
                width: 48,
                child: Poster(url: ApiConfig.urlPoster(f.posterPath)),
              ),
              title: Text(f.titulo,
              style: TextStyle(color: cores.onSurface),
              ),
              subtitle: Text(f.nota == null ? 'Sem nota' : '★' * f.nota!,
              style: TextStyle(color: cores.secondary),
              ),
              trailing: f.favorito
                  ? Icon(Icons.favorite, color: cores.tertiary)
                  : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TelaDetalhesFilme(filmeId: f.filmeId),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
