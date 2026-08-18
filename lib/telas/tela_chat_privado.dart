import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/tema.dart';
import '../controladores/controlador_auth.dart';
import '../controladores/controlador_mensagens_privadas.dart';

class TelaChatPrivado extends StatefulWidget {
  final String conversaId;
  final String nomeOutro;

  const TelaChatPrivado({
    super.key,
    required this.conversaId,
    required this.nomeOutro,
  });

  @override
  State<TelaChatPrivado> createState() => _TelaChatPrivadoState();
}

class _TelaChatPrivadoState extends State<TelaChatPrivado> {
  final _mensagemCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ControladorMensagensPrivadas>(context, listen: false)
          .ouvirMensagens(widget.conversaId);
    });
  }

  void _enviarMensagem() {
    final texto = _mensagemCtrl.text;
    if (texto.trim().isEmpty) return;

    final auth = Provider.of<ControladorAuth>(context, listen: false);
    final msgCtrl =
        Provider.of<ControladorMensagensPrivadas>(context, listen: false);

    if (auth.utilizadorAtual != null) {
      msgCtrl.enviarMensagem(
        widget.conversaId,
        auth.utilizadorAtual!.id,
        texto,
      );
      _mensagemCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final msgCtrl = context.watch<ControladorMensagensPrivadas>();
    final auth = context.watch<ControladorAuth>();
    final meuId = auth.utilizadorAtual?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: TemaMoodi.secundario.withValues(alpha: 0.2),
              child: Text(
                widget.nomeOutro[0].toUpperCase(),
                style: const TextStyle(
                  color: TemaMoodi.secundario,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nomeOutro,
                  style: const TextStyle(fontSize: 16),
                ),
                const Text(
                  'Mensagens expiram em 7 dias',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: TemaMoodi.primarioContainer,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Aviso de expiração
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: TemaMoodi.secundarioContainer.withValues(alpha: 0.3),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, size: 14, color: TemaMoodi.secundario),
                SizedBox(width: 6),
                Text(
                  'As mensagens são apagadas automaticamente após 7 dias',
                  style: TextStyle(
                    fontSize: 11,
                    color: TemaMoodi.secundario,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Mensagens
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: msgCtrl.mensagens.length,
              itemBuilder: (context, index) {
                final msg = msgCtrl.mensagens[index];
                final ehMinha = msg.remetenteId == meuId;

                return Align(
                  alignment:
                      ehMinha ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: ehMinha
                          ? TemaMoodi.primarioContainer
                          : TemaMoodi.superficieVariante,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight:
                            ehMinha ? const Radius.circular(0) : null,
                        bottomLeft:
                            !ehMinha ? const Radius.circular(0) : null,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg.texto,
                          style: TextStyle(
                            color:
                                ehMinha ? Colors.white : TemaMoodi.noFundo,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${msg.dataHora.hour.toString().padLeft(2, '0')}:${msg.dataHora.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 10,
                            color: ehMinha
                                ? Colors.white70
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Campo de mensagem
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensagemCtrl,
                    decoration: InputDecoration(
                      hintText: 'Escreva uma mensagem...',
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
                    onPressed: _enviarMensagem,
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
