import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/tema.dart';
import '../componentes/campo_texto.dart';
import '../componentes/botao_primario.dart';
import '../controladores/controlador_auth.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final _codinomeCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _editando = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<ControladorAuth>(context, listen: false);
    _codinomeCtrl.text = auth.utilizadorAtual?.codinome ?? '';
    _bioCtrl.text = auth.utilizadorAtual?.bio ?? '';
  }

  void _salvar() async {
    final codinome = _codinomeCtrl.text.trim();
    if (codinome.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O codinome deve ter pelo menos 3 caracteres.')),
      );
      return;
    }

    final auth = Provider.of<ControladorAuth>(context, listen: false);
    await auth.atualizarPerfil(
      codinome: codinome,
      bio: _bioCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _editando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ControladorAuth>();
    final utilizador = auth.utilizadorAtual;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: TemaMoodi.noFundo,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_editando)
            IconButton(
              icon: const Icon(Icons.edit, color: TemaMoodi.contorno),
              onPressed: () => setState(() => _editando = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: TemaMoodi.primarioContainer,
              child: Text(
                (utilizador?.codinome ?? '?')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Codinome
            Text(
              utilizador?.codinome ?? 'Anônimo',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 4),
            Text(
              utilizador?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TemaMoodi.contorno,
                  ),
            ),
            const SizedBox(height: 8),

            // Humor Atual
            if (utilizador?.humorAtual != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: TemaMoodi.primarioContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Humor de hoje: ${utilizador!.humorAtual}',
                  style: const TextStyle(
                    color: TemaMoodi.primarioContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 32),

            if (_editando) ...[
              CampoTexto(
                rotulo: 'Codinome',
                dica: 'Seu apelido secreto',
                icone: Icons.masks,
                controlador: _codinomeCtrl,
              ),
              const SizedBox(height: 16),
              CampoTexto(
                rotulo: 'Bio',
                dica: 'Conte algo sobre você...',
                icone: Icons.text_snippet,
                controlador: _bioCtrl,
              ),
              const SizedBox(height: 24),
              BotaoPrimario(
                texto: 'Salvar Alterações',
                icone: Icons.check,
                aoPressionar: _salvar,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => setState(() => _editando = false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ] else ...[
              // Informações em modo leitura
              if (utilizador?.bio != null && utilizador!.bio!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: TemaMoodi.superficieBaixa,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bio',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: TemaMoodi.contorno,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        utilizador.bio!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // Botão Sair
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await auth.sair();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text('Sair da Conta',
                      style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
