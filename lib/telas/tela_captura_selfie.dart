import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../componentes/tema.dart';
import '../servicos/servico_camera.dart';

import '../servicos/servico_ia.dart';
import '../controladores/controlador_humor.dart';
import '../controladores/controlador_auth.dart';
import 'package:provider/provider.dart';

class TelaCapturaSelfie extends StatefulWidget {
  const TelaCapturaSelfie({super.key});

  @override
  State<TelaCapturaSelfie> createState() => _TelaCapturaSelfieState();
}

class _TelaCapturaSelfieState extends State<TelaCapturaSelfie> {
  final ServicoCamera _servicoCamera = ServicoCamera();
  final ServicoIA _servicoIA = ServicoIA();
  bool _inicializando = true;
  bool _analisando = false;
  XFile? _fotoTirada;
  Uint8List? _fotoBytes;

  @override
  void initState() {
    super.initState();
    _iniciarCamera();
  }

  Future<void> _iniciarCamera() async {
    await _servicoCamera.inicializar();
    if (mounted) {
      setState(() {
        _inicializando = false;
      });
    }
  }

  @override
  void dispose() {
    _servicoCamera.descartar();
    super.dispose();
  }

  void _tirarFoto() async {
    final foto = await _servicoCamera.tirarFoto();
    if (foto != null && mounted) {
      final bytes = await foto.readAsBytes();
      setState(() {
        _fotoTirada = foto;
        _fotoBytes = bytes;
      });
    }
  }

  Future<void> _enviarFoto() async {
    if (_fotoBytes == null) return;
    
    setState(() => _analisando = true);
    
    try {
      // 1. Analisa a foto via Gemini
      final humorDetetado = await _servicoIA.analisarHumor(_fotoBytes!);
      
      if (!mounted) return;
      
      setState(() => _analisando = false);
      
      // 2. Mostra dialog de confirmação
      if (humorDetetado != null) {
        _mostrarDialogConfirmacao(humorDetetado);
      } else {
        _mostrarDialogConfirmacao('Neutro');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _analisando = false);
      
      // Em caso de erro, oferece escolha manual
      _mostrarDialogErro(e.toString());
    }
  }

  void _mostrarDialogConfirmacao(String humorDetetado) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.psychology, color: TemaMoodi.primarioContainer),
            SizedBox(width: 8),
            Text('Humor Detetado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TemaMoodi.primarioContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                humorDetetado,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: TemaMoodi.primarioContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'A IA detetou este humor.\nDeseja confirmar ou escolher manualmente?',
              textAlign: TextAlign.center,
              style: TextStyle(color: TemaMoodi.contorno),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _fotoTirada = null;
                _fotoBytes = null;
              });
            },
            child: const Text('Repetir Foto'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _mostrarSelectorManual();
            },
            child: const Text('Escolher Manualmente'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _registrarHumor(humorDetetado);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TemaMoodi.primarioContainer,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogErro(String erro) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Erro na IA'),
          ],
        ),
        content: const Text(
          'Não foi possível analisar a foto.\nDeseja escolher o humor manualmente?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _fotoTirada = null;
                _fotoBytes = null;
              });
            },
            child: const Text('Tentar Novamente'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _mostrarSelectorManual();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TemaMoodi.primarioContainer,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Escolher Manualmente'),
          ),
        ],
      ),
    );
  }

  void _mostrarSelectorManual() {
    const humores = [
      {'humor': 'Feliz', 'icone': Icons.sentiment_very_satisfied, 'cor': Colors.orange},
      {'humor': 'Calmo', 'icone': Icons.self_improvement, 'cor': Colors.teal},
      {'humor': 'Neutro', 'icone': Icons.sentiment_neutral, 'cor': Colors.grey},
      {'humor': 'Ansioso', 'icone': Icons.psychology, 'cor': Colors.purple},
      {'humor': 'Triste', 'icone': Icons.sentiment_dissatisfied, 'cor': Colors.blue},
      {'humor': 'Raivoso', 'icone': Icons.local_fire_department, 'cor': Colors.red},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Escolha o seu Humor'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: humores.map((h) {
            return InkWell(
              onTap: () {
                Navigator.pop(ctx);
                _registrarHumor(h['humor'] as String);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 90,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: (h['cor'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: (h['cor'] as Color).withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(h['icone'] as IconData,
                        color: h['cor'] as Color, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      h['humor'] as String,
                      style: TextStyle(
                        color: h['cor'] as Color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _registrarHumor(String humor) async {
    final auth = context.read<ControladorAuth>();
    if (auth.utilizadorAtual != null) {
      final sucesso = await context.read<ControladorHumor>().registrarHumor(
        auth.utilizadorAtual!.id,
        humor,
        null,
      );
      
      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Humor registrado: $humor! 🎉')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Já registou o seu humor hoje!')),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_inicializando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_servicoCamera.controlador == null || !_servicoCamera.controlador!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Câmera Indisponível')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 64, color: TemaMoodi.contorno),
              const SizedBox(height: 16),
              Text(
                kIsWeb
                    ? 'A câmera não está disponível no navegador.\nPermita o acesso ou use o app Android.'
                    : 'Não foi possível iniciar a câmera.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: TemaMoodi.contorno),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_fotoTirada == null || _fotoBytes == null)
            Positioned.fill(
              child: CameraPreview(_servicoCamera.controlador!),
            )
          else
            Positioned.fill(
              child: Image.memory(
                _fotoBytes!,
                fit: BoxFit.cover,
              ),
            ),
          
          // Overlay UI
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_fotoTirada == null)
                  GestureDetector(
                    onTap: _tirarFoto,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: TemaMoodi.primarioContainer.withValues(alpha: 0.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 32),
                      ),
                    ),
                  )
                else ...[
                  ElevatedButton.icon(
                    onPressed: _analisando ? null : () => setState(() {
                      _fotoTirada = null;
                      _fotoBytes = null;
                    }),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _analisando 
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _enviarFoto,
                        icon: const Icon(Icons.send),
                        label: const Text('Analisar Humor'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TemaMoodi.primarioContainer,
                          foregroundColor: Colors.white,
                        ),
                      ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}
