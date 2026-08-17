import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../modelos/mensagem.dart';
import '../servicos/servico_banco_dados.dart';

class ControladorChat extends ChangeNotifier {
  final ServicoBancoDados _servicoBancoDados = ServicoBancoDados();

  List<Mensagem> _mensagens = [];
  final bool _carregando = false;

  List<Mensagem> get mensagens => _mensagens;
  bool get carregando => _carregando;

  void ouvirMensagens(String salaId) {
    _servicoBancoDados.streamMensagens(salaId).listen((dados) {
      _mensagens = dados;
      notifyListeners();
    });
  }

  Future<void> enviarMensagem(String salaId, String remetenteId, String texto) async {
    if (texto.trim().isEmpty) return;
    
    try {
      final novaMensagem = Mensagem(
        id: '', // Gerado pelo Firestore
        remetenteId: remetenteId,
        texto: texto.trim(),
        dataHora: DateTime.now(),
      );
      await _servicoBancoDados.enviarMensagem(salaId, novaMensagem);
    } catch (e) {
      debugPrint('Erro ao enviar mensagem: $e');
    }
  }
}
