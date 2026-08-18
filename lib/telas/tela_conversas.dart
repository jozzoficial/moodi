import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/tema.dart';
import '../controladores/controlador_auth.dart';
import '../controladores/controlador_mensagens_privadas.dart';
import 'tela_chat_privado.dart';

class TelaConversas extends StatefulWidget {
  const TelaConversas({super.key});

  @override
  State<TelaConversas> createState() => _TelaConversasState();
}

class _TelaConversasState extends State<TelaConversas> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<ControladorAuth>(context, listen: false);
      final msgCtrl =
          Provider.of<ControladorMensagensPrivadas>(context, listen: false);

      if (auth.utilizadorAtual != null) {
        msgCtrl.ouvirConversas(auth.utilizadorAtual!.id);
      }
    });
  }

  String _tempoRelativo(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inMinutes < 1) return 'agora';
    if (diferenca.inMinutes < 60) return '${diferenca.inMinutes}min';
    if (diferenca.inHours < 24) return '${diferenca.inHours}h';
    if (diferenca.inDays < 7) return '${diferenca.inDays}d';
    return '${data.day}/${data.month}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ControladorAuth>();
    final msgCtrl = context.watch<ControladorMensagensPrivadas>();
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
          'Mensagens',
          style: TextStyle(
            color: TemaMoodi.noFundo,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: msgCtrl.conversas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Sem conversas ainda.\nClique no perfil de alguém na Comunidade\npara iniciar uma conversa!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: msgCtrl.conversas.length,
              itemBuilder: (context, index) {
                final conversa = msgCtrl.conversas[index];

                // Descobre o codinome do outro participante
                final outroUid = conversa.participantes
                    .firstWhere((uid) => uid != meuUid, orElse: () => '');
                final outroCodinome =
                    conversa.codinomes[outroUid] ?? 'Utilizador';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  color: TemaMoodi.superficieBaixa,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: TemaMoodi.secundario.withValues(alpha: 0.2),
                      child: Text(
                        outroCodinome[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: TemaMoodi.secundario,
                        ),
                      ),
                    ),
                    title: Text(
                      outroCodinome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      conversa.ultimaMensagem.isEmpty
                          ? 'Conversa iniciada'
                          : conversa.ultimaMensagem,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: Text(
                      _tempoRelativo(conversa.dataUltimaMensagem),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TelaChatPrivado(
                            conversaId: conversa.id,
                            nomeOutro: outroCodinome,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
