import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class ServicoCamera {
  CameraController? _controlador;
  List<CameraDescription>? _cameras;

  Future<void> inicializar() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      // Prioriza a câmera frontal
      final cameraFrontal = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controlador = CameraController(
        cameraFrontal,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controlador!.initialize();
    }
  }

  CameraController? get controlador => _controlador;

  Future<XFile?> tirarFoto() async {
    if (_controlador != null && _controlador!.value.isInitialized) {
      try {
        return await _controlador!.takePicture();
      } catch (e) {
        debugPrint('Erro ao tirar foto: $e');
        return null;
      }
    }
    return null;
  }

  void descartar() {
    _controlador?.dispose();
  }
}
