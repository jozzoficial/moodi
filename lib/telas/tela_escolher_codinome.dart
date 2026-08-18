import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/tema.dart';
import '../componentes/botao_primario.dart';
import '../componentes/campo_texto.dart';
import '../controladores/controlador_auth.dart';
import 'tela_dashboard.dart';

class TelaEscolherCodinome extends StatefulWidget {
  const TelaEscolherCodinome({super.key});

  @override
  State<TelaEscolherCodinome> createState() => _TelaEscolherCodinomeState();
}

class _TelaEscolherCodinomeState extends State<TelaEscolherCodinome> {
  final _codinomeCtrl = TextEditingController();

  void _confirmar() async {
    final codinome = _codinomeCtrl.text.trim();
    if (codinome.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O codinome deve ter pelo menos 3 caracteres.')),
      );
      return;
    }

    final auth = Provider.of<ControladorAuth>(context, listen: false);
    await auth.atualizarPerfil(codinome: codinome);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.face_6, size: 80, color: TemaMoodi.primario),
              const SizedBox(height: 16),
              Text(
                'Escolha o seu Codinome',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Este é o seu nome anónimo na comunidade.\nPode alterá-lo a qualquer momento no Perfil.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TemaMoodi.contorno,
                    ),
              ),
              const SizedBox(height: 48),
              CampoTexto(
                rotulo: 'Codinome',
                dica: 'Ex: LuaCheia, Poeta42...',
                icone: Icons.masks,
                controlador: _codinomeCtrl,
              ),
              const SizedBox(height: 32),
              BotaoPrimario(
                texto: 'Continuar',
                icone: Icons.arrow_forward,
                aoPressionar: _confirmar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
