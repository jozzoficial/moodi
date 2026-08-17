import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../modelos/entrada_humor.dart';
import '../servicos/servico_banco_dados.dart';

class ControladorHumor extends ChangeNotifier {
  final ServicoBancoDados _servicoBancoDados = ServicoBancoDados();

  List<EntradaHumor> _humores = [];
  bool _carregando = false;

  List<EntradaHumor> get humores => _humores;
  bool get carregando => _carregando;

  // Carrega os humores de um utilizador e atualiza a interface via Stream
  void ouvirHumores(String utilizadorId) {
    _servicoBancoDados.streamHumores(utilizadorId).listen((dados) {
      _humores = dados;
      notifyListeners();
    });
  }

  Future<void> registrarHumor(String utilizadorId, String humor, String? fotoUrl) async {
    _setCarregando(true);
    try {
      final agora = DateTime.now();
      
      // Verifica se já existe um humor para hoje
      EntradaHumor? entradaDeHoje;
      for (var entrada in _humores) {
        if (entrada.dataHora.year == agora.year &&
            entrada.dataHora.month == agora.month &&
            entrada.dataHora.day == agora.day) {
          entradaDeHoje = entrada;
          break;
        }
      }

      if (entradaDeHoje != null) {
        // Atualiza a entrada existente
        final entradaAtualizada = EntradaHumor(
          id: entradaDeHoje.id,
          utilizadorId: utilizadorId,
          humor: humor,
          dataHora: agora,
          fotoUrl: fotoUrl ?? entradaDeHoje.fotoUrl,
        );
        await _servicoBancoDados.atualizarEntradaHumor(entradaDeHoje.id, entradaAtualizada);
      } else {
        // Cria nova entrada
        final novaEntrada = EntradaHumor(
          id: '', // Gerado pelo Firestore
          utilizadorId: utilizadorId,
          humor: humor,
          dataHora: agora,
          fotoUrl: fotoUrl,
        );
        await _servicoBancoDados.adicionarEntradaHumor(novaEntrada);
      }
    } catch (e) {
      debugPrint('Erro ao registrar humor: $e');
    }
    _setCarregando(false);
  }

  void _setCarregando(bool valor) {
    _carregando = valor;
    notifyListeners();
  }
}
