import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../modelos/mensagem.dart';
import '../modelos/conversa_privada.dart';
import '../servicos/servico_banco_dados.dart';

class ControladorMensagensPrivadas extends ChangeNotifier {
  final ServicoBancoDados _servicoBancoDados = ServicoBancoDados();

  List<ConversaPrivada> _conversas = [];
  List<Mensagem> _mensagens = [];

  List<ConversaPrivada> get conversas => _conversas;
  List<Mensagem> get mensagens => _mensagens;

  /// Ouve as conversas do utilizador
  void ouvirConversas(String uid) {
    _servicoBancoDados.streamConversas(uid).listen((dados) {
      _conversas = dados;
      notifyListeners();
    });
  }

  /// Ouve as mensagens de uma conversa específica
  void ouvirMensagens(String conversaId) {
    _servicoBancoDados.streamMensagensPrivadas(conversaId).listen((dados) {
      // Filtra mensagens expiradas localmente
      final agora = DateTime.now();
      _mensagens = dados.where((msg) {
        if (msg.expiraEm == null) return true;
        return agora.isBefore(msg.expiraEm!);
      }).toList();
      notifyListeners();
    });

    // Limpa mensagens expiradas no Firestore
    _servicoBancoDados.limparMensagensExpiradas(conversaId);
  }

  /// Inicia ou obtém uma conversa privada
  Future<ConversaPrivada> iniciarConversa(
    String meuUid, String outroUid,
    String meuCodinome, String outroCodinome,
  ) async {
    return await _servicoBancoDados.criarOuObterConversa(
      meuUid, outroUid, meuCodinome, outroCodinome,
    );
  }

  /// Envia uma mensagem privada (com expiração de 7 dias)
  Future<void> enviarMensagem(String conversaId, String remetenteId, String texto) async {
    if (texto.trim().isEmpty) return;

    try {
      final agora = DateTime.now();
      final mensagem = Mensagem(
        id: '',
        remetenteId: remetenteId,
        texto: texto.trim(),
        dataHora: agora,
        expiraEm: agora.add(const Duration(days: 7)),
      );
      await _servicoBancoDados.enviarMensagemPrivada(conversaId, mensagem);
    } catch (e) {
      debugPrint('Erro ao enviar mensagem privada: $e');
    }
  }
}
