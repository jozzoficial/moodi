import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/tema.dart';
import '../componentes/botao_primario.dart';
import '../componentes/campo_texto.dart';
import '../controladores/controlador_auth.dart';
import 'tela_cadastro.dart';
import 'tela_dashboard.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  void _entrar() async {
    final auth = Provider.of<ControladorAuth>(context, listen: false);
    bool sucesso = await auth.entrar(_emailCtrl.text, _senhaCtrl.text);

    if (!mounted) return;

    if (sucesso) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao entrar. Verifique suas credenciais.')),
      );
    }
  }

  void _entrarComGoogle() async {
    final auth = Provider.of<ControladorAuth>(context, listen: false);
    bool sucesso = await auth.entrarComGoogle();

    if (!mounted) return;

    if (sucesso) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao entrar com o Google.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final carregando = context.watch<ControladorAuth>().carregando;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.face_6, size: 80, color: TemaMoodi.primario),
              const SizedBox(height: 16),
              Text(
                'Bem-vindo de volta',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Entre para continuar sua jornada.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TemaMoodi.contorno,
                    ),
              ),
              const SizedBox(height: 48),
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
                texto: 'Entrar',
                icone: Icons.login,
                carregando: carregando,
                aoPressionar: _entrar,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: carregando ? null : _entrarComGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 32),
                  label: const Text('Entrar com Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: TemaMoodi.contorno),
                    foregroundColor: TemaMoodi.noFundo,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaCadastro()),
                  );
                },
                child: const Text(
                  'Não tem uma conta? Crie aqui',
                  style: TextStyle(
                    color: TemaMoodi.secundario,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
