import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/tema.dart';
import '../modelos/publicacao.dart';
import '../modelos/comentario.dart';
import '../controladores/controlador_auth.dart';
import '../controladores/controlador_comunidade.dart';

class TelaComentarios extends StatefulWidget {
  final Publicacao publicacao;

  const TelaComentarios({super.key, required this.publicacao});

  @override
  State<TelaComentarios> createState() => _TelaComentariosState();
}

class _TelaComentariosState extends State<TelaComentarios> {
  final _comentarioCtrl = TextEditingController();

  void _enviarComentario() {
    final texto = _comentarioCtrl.text.trim();
    if (texto.isEmpty) return;

    final auth = Provider.of<ControladorAuth>(context, listen: false);
    final comunidade = Provider.of<ControladorComunidade>(context, listen: false);

    if (auth.utilizadorAtual != null) {
      comunidade.comentar(
        publicacaoId: widget.publicacao.id,
        autorId: auth.utilizadorAtual!.id,
        autorCodinome: auth.utilizadorAtual!.codinome,
        texto: texto,
      );
      _comentarioCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final comunidade = context.watch<ControladorComunidade>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TemaMoodi.contorno),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Comentários',
          style: TextStyle(
            color: TemaMoodi.noFundo,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Publicação original
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: TemaMoodi.superficieBaixa,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: TemaMoodi.primarioContainer,
                      child: Text(
                        widget.publicacao.autorCodinome[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.publicacao.autorCodinome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(widget.publicacao.texto),
              ],
            ),
          ),
          const Divider(height: 1),

          // Lista de comentários
          Expanded(
            child: StreamBuilder<List<Comentario>>(
              stream: comunidade.streamComentarios(widget.publicacao.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final comentarios = snapshot.data!;
                if (comentarios.isEmpty) {
                  return Center(
                    child: Text(
                      'Ainda não há comentários.\nSeja o primeiro!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comentarios.length,
                  itemBuilder: (context, index) {
                    final c = comentarios[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                TemaMoodi.secundario.withValues(alpha: 0.2),
                            child: Text(
                              c.autorCodinome[0].toUpperCase(),
                              style: const TextStyle(
                                color: TemaMoodi.secundario,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: TemaMoodi.superficieBaixa,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.autorCodinome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(c.texto),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Campo de comentário
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _comentarioCtrl,
                    decoration: InputDecoration(
                      hintText: 'Escreva um comentário...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: TemaMoodi.superficieBaixa,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: TemaMoodi.primarioContainer,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _enviarComentario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
