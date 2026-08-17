import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/tema.dart';
import '../controladores/controlador_chat.dart';
import '../controladores/controlador_auth.dart';

class TelaChat extends StatefulWidget {
  final String salaId;
  final String nomeSala;

  const TelaChat({
    super.key,
    required this.salaId,
    required this.nomeSala,
  });

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final _mensagemCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ControladorChat>(context, listen: false).ouvirMensagens(widget.salaId);
    });
  }

  void _enviarMensagem() {
    final texto = _mensagemCtrl.text;
    if (texto.isEmpty) return;

    final auth = Provider.of<ControladorAuth>(context, listen: false);
    final chat = Provider.of<ControladorChat>(context, listen: false);

    if (auth.utilizadorAtual != null) {
      chat.enviarMensagem(widget.salaId, auth.utilizadorAtual!.id, texto);
      _mensagemCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ControladorChat>();
    final auth = context.watch<ControladorAuth>();
    final meuId = auth.utilizadorAtual?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomeSala),
        backgroundColor: TemaMoodi.primarioContainer,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chat.mensagens.length,
              itemBuilder: (context, index) {
                final msg = chat.mensagens[index];
                final ehMinha = msg.remetenteId == meuId;

                return Align(
                  alignment: ehMinha ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ehMinha ? TemaMoodi.primarioContainer : TemaMoodi.superficieVariante,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: ehMinha ? const Radius.circular(0) : null,
                        bottomLeft: !ehMinha ? const Radius.circular(0) : null,
                      ),
                    ),
                    child: Text(
                      msg.texto,
                      style: TextStyle(
                        color: ehMinha ? Colors.white : TemaMoodi.noFundo,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensagemCtrl,
                    decoration: InputDecoration(
                      hintText: 'Digite uma mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: TemaMoodi.superficieBaixa,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
