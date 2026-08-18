import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/tema.dart';
import '../controladores/controlador_auth.dart';
import '../controladores/controlador_humor.dart';
import '../controladores/controlador_comunidade.dart';

class TelaCriarPublicacao extends StatefulWidget {
  const TelaCriarPublicacao({super.key});

  @override
  State<TelaCriarPublicacao> createState() => _TelaCriarPublicacaoState();
}

class _TelaCriarPublicacaoState extends State<TelaCriarPublicacao> {
  final _textoCtrl = TextEditingController();
  bool _publicando = false;

  void _publicar() async {
    final texto = _textoCtrl.text.trim();
    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escreva algo antes de publicar.')),
      );
      return;
    }

    setState(() => _publicando = true);

    final auth = Provider.of<ControladorAuth>(context, listen: false);
    final humor = Provider.of<ControladorHumor>(context, listen: false);
    final comunidade = Provider.of<ControladorComunidade>(context, listen: false);

    final utilizador = auth.utilizadorAtual;
    if (utilizador == null) return;

    final humorHoje = humor.humorDeHoje(utilizador.id) ?? 'Neutro';

    await comunidade.criarPublicacao(
      autorId: utilizador.id,
      autorCodinome: utilizador.codinome,
      humor: humorHoje,
      texto: texto,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ControladorAuth>();
    final humor = context.watch<ControladorHumor>();
    final humorHoje = humor.humorDeHoje(auth.utilizadorAtual?.id ?? '') ?? 'Neutro';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: TemaMoodi.contorno),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nova Publicação',
          style: TextStyle(
            color: TemaMoodi.noFundo,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: _publicando ? null : _publicar,
              style: ElevatedButton.styleFrom(
                backgroundColor: TemaMoodi.primarioContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _publicando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Publicar'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: TemaMoodi.primarioContainer,
                  child: Text(
                    (auth.utilizadorAtual?.codinome ?? '?')[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.utilizadorAtual?.codinome ?? 'Anônimo',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: TemaMoodi.secundarioContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Humor: $humorHoje',
                        style: const TextStyle(
                          fontSize: 11,
                          color: TemaMoodi.secundario,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _textoCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'O que está a sentir hoje?',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
