import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/tema.dart';
import '../componentes/barra_navegacao.dart';
import '../componentes/grafico_humor.dart';
import '../controladores/controlador_auth.dart';
import '../controladores/controlador_humor.dart';
import 'tela_comunidade.dart';
import 'tela_conversas.dart';
import 'tela_captura_selfie.dart';
import 'tela_perfil.dart';

class TelaDashboard extends StatefulWidget {
  const TelaDashboard({super.key});

  @override
  State<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends State<TelaDashboard> {
  int _abaAtual = 0;

  void _aoMudarAba(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TelaCapturaSelfie()),
      );
      return;
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TelaComunidade()),
      );
      return;
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TelaConversas()),
      );
      return;
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TelaPerfil()),
      );
      return;
    }
    setState(() {
      _abaAtual = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<ControladorAuth>(context, listen: false);
      if (auth.utilizadorAtual != null) {
        Provider.of<ControladorHumor>(context, listen: false)
            .ouvirHumores(auth.utilizadorAtual!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ControladorAuth>();
    final controladorHumor = context.watch<ControladorHumor>();
    final codinome = auth.utilizadorAtual?.codinome ?? 'Visitante';
    final jaRegistrou = auth.utilizadorAtual != null &&
        controladorHumor.jaRegistrouHoje(auth.utilizadorAtual!.id);

    // Calcular dados reais para o gráfico com base em todos os humores
    final humores = controladorHumor.humores;
    Map<String, double> dadosHumor = {};
    if (humores.isNotEmpty) {
      Map<String, int> contagem = {};
      for (var entrada in humores) {
        contagem[entrada.humor] = (contagem[entrada.humor] ?? 0) + 1;
      }
      contagem.forEach((chave, valor) {
        dadosHumor[chave] = (valor / humores.length) * 100.0;
      });
    } else {
      // Dados vazios se não houver registros
      dadosHumor = {'Sem dados': 100.0};
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.face_6, color: TemaMoodi.primarioContainer),
            const SizedBox(width: 8),
            Text(
              'Mood¡',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: TemaMoodi.primarioContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá $codinome,',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Text(
              jaRegistrou
                  ? 'já registou o seu humor de hoje! 🎉'
                  : 'como está o seu dia?',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: TemaMoodi.contorno,
                  ),
            ),
            const SizedBox(height: 32),
            
            // Botão Adicionar com Selfie
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: jaRegistrou
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TelaCapturaSelfie()),
                        );
                      },
                icon: Icon(jaRegistrou ? Icons.check_circle : Icons.camera_alt),
                label: Text(jaRegistrou
                    ? 'Humor já registado hoje'
                    : 'Registrar Humor com Selfie'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: jaRegistrou
                      ? Colors.grey.shade400
                      : TemaMoodi.primario,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Registro Manual
            if (!jaRegistrou) ...[
              Text(
                'Ou registre manualmente:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: TemaMoodi.contorno,
                    ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _BotaoHumorManual(
                        icone: Icons.sentiment_very_satisfied,
                        humor: 'Feliz',
                        cor: Colors.orange),
                    _BotaoHumorManual(
                        icone: Icons.self_improvement,
                        humor: 'Calmo',
                        cor: Colors.teal),
                    _BotaoHumorManual(
                        icone: Icons.sentiment_neutral,
                        humor: 'Neutro',
                        cor: Colors.grey),
                    _BotaoHumorManual(
                        icone: Icons.psychology,
                        humor: 'Ansioso',
                        cor: Colors.purple),
                    _BotaoHumorManual(
                        icone: Icons.sentiment_dissatisfied,
                        humor: 'Triste',
                        cor: Colors.blue),
                    _BotaoHumorManual(
                        icone: Icons.local_fire_department,
                        humor: 'Raivoso',
                        cor: Colors.red),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ] else
              const SizedBox(height: 8),

            // Gráfico do Humor
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: TemaMoodi.primarioContainer.withValues(alpha: 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Seu Histórico de Humor',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: TemaMoodi.contorno,
                        ),
                  ),
                  const SizedBox(height: 16),
                  GraficoHumor(dadosHumor: dadosHumor),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Citação
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TemaMoodi.secundarioContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: TemaMoodi.secundario.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.format_quote,
                      size: 32, color: TemaMoodi.secundario),
                  const SizedBox(height: 16),
                  Text(
                    '"A felicidade não é algo pronto. Ela vem de suas próprias ações." - (Ou talvez você só precise de um café)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: TemaMoodi.secundario,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BarraNavegacao(
        indiceAtual: _abaAtual,
        aoMudarAba: _aoMudarAba,
      ),
    );
  }
}

class _BotaoHumorManual extends StatelessWidget {
  final IconData icone;
  final String humor;
  final Color cor;

  const _BotaoHumorManual({
    required this.icone,
    required this.humor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: InkWell(
        onTap: () async {
          final auth = context.read<ControladorAuth>();
          if (auth.utilizadorAtual != null) {
            final sucesso = await context.read<ControladorHumor>().registrarHumor(
              auth.utilizadorAtual!.id,
              humor,
              null,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(sucesso
                      ? 'Humor registrado como: $humor'
                      : 'Já registou o seu humor hoje!'),
                ),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cor.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, color: cor, size: 32),
              const SizedBox(height: 8),
              Text(
                humor,
                style: TextStyle(
                  color: cor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
