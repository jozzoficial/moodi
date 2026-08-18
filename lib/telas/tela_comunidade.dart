import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/tema.dart';
import '../componentes/card_publicacao.dart';
import '../controladores/controlador_auth.dart';
import '../controladores/controlador_humor.dart';
import '../controladores/controlador_comunidade.dart';
import '../controladores/controlador_mensagens_privadas.dart';
import 'tela_criar_publicacao.dart';
import 'tela_comentarios.dart';
import 'tela_chat_privado.dart';

class TelaComunidade extends StatefulWidget {
  const TelaComunidade({super.key});

  @override
  State<TelaComunidade> createState() => _TelaComunidadeState();
}

class _TelaComunidadeState extends State<TelaComunidade> {
  static const _humores = ['Feliz', 'Calmo', 'Neutro', 'Ansioso', 'Triste', 'Raivoso'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<ControladorAuth>(context, listen: false);
      final humor = Provider.of<ControladorHumor>(context, listen: false);
      final comunidade = Provider.of<ControladorComunidade>(context, listen: false);
      
      if (auth.utilizadorAtual != null) {
        // Filtra por humor de hoje, ou 'Feliz' como padrão
        final humorHoje = humor.humorDeHoje(auth.utilizadorAtual!.id) ?? 'Feliz';
        comunidade.ouvirPublicacoes(humorHoje);
      }
    });
  }

  void _abrirCriarPublicacao() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TelaCriarPublicacao()),
    );
  }

  void _enviarMensagem(String autorId, String autorCodinome) async {
    final auth = Provider.of<ControladorAuth>(context, listen: false);
    final msgCtrl = Provider.of<ControladorMensagensPrivadas>(context, listen: false);
    
    if (auth.utilizadorAtual == null || autorId == auth.utilizadorAtual!.id) return;

    final conversa = await msgCtrl.iniciarConversa(
      auth.utilizadorAtual!.id,
      autorId,
      auth.utilizadorAtual!.codinome,
      autorCodinome,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TelaChatPrivado(
            conversaId: conversa.id,
            nomeOutro: autorCodinome,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ControladorAuth>();
    final comunidade = context.watch<ControladorComunidade>();
    final meuUid = auth.utilizadorAtual?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TemaMoodi.contorno),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Comunidade',
          style: TextStyle(
            color: TemaMoodi.noFundo,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtros de humor
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _humores.length,
              itemBuilder: (context, index) {
                final humor = _humores[index];
                final ativo = comunidade.humorFiltro == humor;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: ativo,
                    label: Text(humor),
                    selectedColor: TemaMoodi.primarioContainer.withValues(alpha: 0.2),
                    checkmarkColor: TemaMoodi.primarioContainer,
                    onSelected: (_) => comunidade.mudarFiltro(humor),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Feed de publicações
          Expanded(
            child: comunidade.publicacoes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma publicação neste humor.\nSeja o primeiro a partilhar!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: comunidade.publicacoes.length,
                    itemBuilder: (context, index) {
                      final pub = comunidade.publicacoes[index];
                      return CardPublicacao(
                        publicacao: pub,
                        meuUid: meuUid,
                        aoClicarLike: () =>
                            comunidade.toggleLike(pub.id, meuUid),
                        aoClicarComentar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TelaComentarios(publicacao: pub),
                            ),
                          );
                        },
                        aoClicarAutor: pub.autorId != meuUid
                            ? () => _enviarMensagem(pub.autorId, pub.autorCodinome)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCriarPublicacao,
        backgroundColor: TemaMoodi.primarioContainer,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('Publicar'),
      ),
    );
  }
}
