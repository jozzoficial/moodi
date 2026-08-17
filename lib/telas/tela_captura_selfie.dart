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
      
      // 2. Regista o humor se encontrou algo
      if (humorDetetado != null) {
        final auth = context.read<ControladorAuth>();
        if (auth.utilizadorAtual != null) {
          await context.read<ControladorHumor>().registrarHumor(
            auth.utilizadorAtual!.id,
            humorDetetado,
            null, // A foto não é guardada, apenas o humor
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Humor detetado: $humorDetetado! Registrado com sucesso.')),
            );
            Navigator.pop(context); // Volta ao Dashboard
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível detetar o humor. Tente novamente.')),
        );
        setState(() => _analisando = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _analisando = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Erro na IA'),
          content: SingleChildScrollView(
            child: Text(e.toString()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
