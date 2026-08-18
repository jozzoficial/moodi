import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/tema.dart';
import '../componentes/botao_primario.dart';
import '../componentes/campo_texto.dart';
import '../controladores/controlador_auth.dart';
import 'tela_dashboard.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _codinomeCtrl = TextEditingController();

  void _registrar() async {
    final codinome = _codinomeCtrl.text.trim();
    if (codinome.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O codinome deve ter pelo menos 3 caracteres.')),
      );
      return;
    }

    final auth = Provider.of<ControladorAuth>(context, listen: false);
    bool sucesso = await auth.registrar(
      _emailCtrl.text,
      _senhaCtrl.text,
      codinome,
    );

    if (!mounted) return;

    if (sucesso) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao registrar. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final carregando = context.watch<ControladorAuth>().carregando;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TemaMoodi.contorno),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mood¡',
          style: TextStyle(
            color: TemaMoodi.primarioContainer,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.face_6, size: 80, color: TemaMoodi.primario),
            const SizedBox(height: 16),
            Text(
              'Junte-se a nós',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Crie sua conta e comece sua jornada.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TemaMoodi.contorno,
                  ),
            ),
            const SizedBox(height: 48),
            CampoTexto(
              rotulo: 'Codinome (Anônimo)',
              dica: 'Seu apelido secreto',
              icone: Icons.masks,
              controlador: _codinomeCtrl,
            ),
            const SizedBox(height: 16),
            CampoTexto(
              rotulo: 'E-mail',
              dica: 'exemplo@email.com',
              icone: Icons.email,
              tipoTeclado: TextInputType.emailAddress,
              controlador: _emailCtrl,
            ),
            const SizedBox(height: 16),
            CampoTexto(
              rotulo: 'Senha',
              dica: '••••••••',
              icone: Icons.visibility,
              ocultarTexto: true,
              controlador: _senhaCtrl,
            ),
            const SizedBox(height: 32),
            BotaoPrimario(
              texto: 'Criar Conta',
              icone: Icons.arrow_forward,
              carregando: carregando,
              aoPressionar: _registrar,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Já possui uma conta? Entrar agora',
                style: TextStyle(
                  color: TemaMoodi.secundario,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
