import 'package:flutter/material.dart';
import '../modelos/publicacao.dart';
import 'tema.dart';

class CardPublicacao extends StatelessWidget {
  final Publicacao publicacao;
  final String meuUid;
  final VoidCallback aoClicarLike;
  final VoidCallback aoClicarComentar;
  final VoidCallback? aoClicarAutor;

  const CardPublicacao({
    super.key,
    required this.publicacao,
    required this.meuUid,
    required this.aoClicarLike,
    required this.aoClicarComentar,
    this.aoClicarAutor,
  });

  String _tempoRelativo(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inMinutes < 1) return 'agora';
    if (diferenca.inMinutes < 60) return 'há ${diferenca.inMinutes}min';
    if (diferenca.inHours < 24) return 'há ${diferenca.inHours}h';
    if (diferenca.inDays < 7) return 'há ${diferenca.inDays}d';
    return '${data.day}/${data.month}/${data.year}';
  }

  Color _corDoHumor(String humor) {
    switch (humor) {
      case 'Feliz': return Colors.orange;
      case 'Calmo': return Colors.teal;
      case 'Neutro': return Colors.grey;
      case 'Ansioso': return Colors.purple;
      case 'Triste': return Colors.blue;
      case 'Raivoso': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final jaDeuLike = publicacao.likesUids.contains(meuUid);
    final corHumor = _corDoHumor(publicacao.humor);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: aoClicarAutor,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: corHumor.withValues(alpha: 0.2),
                    child: Text(
                      publicacao.autorCodinome[0].toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: corHumor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: aoClicarAutor,
                        child: Text(
                          publicacao.autorCodinome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: corHumor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              publicacao.humor,
                              style: TextStyle(
                                fontSize: 11,
                                color: corHumor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _tempoRelativo(publicacao.dataHora),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              publicacao.texto,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),

          // Separador
          Divider(height: 1, color: Colors.grey.shade100),

          // Barra de ações
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Like
                TextButton.icon(
                  onPressed: aoClicarLike,
                  icon: Icon(
                    jaDeuLike ? Icons.favorite : Icons.favorite_border,
                    color: jaDeuLike ? Colors.redAccent : TemaMoodi.contorno,
                    size: 20,
                  ),
                  label: Text(
                    '${publicacao.totalLikes}',
                    style: TextStyle(
                      color: jaDeuLike ? Colors.redAccent : TemaMoodi.contorno,
                    ),
                  ),
                ),
                // Comentar
                TextButton.icon(
                  onPressed: aoClicarComentar,
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: TemaMoodi.contorno,
                    size: 20,
                  ),
                  label: Text(
                    '${publicacao.totalComentarios}',
                    style: const TextStyle(color: TemaMoodi.contorno),
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
