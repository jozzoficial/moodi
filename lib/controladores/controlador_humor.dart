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

  /// Verifica se o utilizador já registou o humor hoje
  bool jaRegistrouHoje(String utilizadorId) {
    final agora = DateTime.now();
    for (var entrada in _humores) {
      if (entrada.utilizadorId == utilizadorId &&
          entrada.dataHora.year == agora.year &&
          entrada.dataHora.month == agora.month &&
          entrada.dataHora.day == agora.day) {
        return true;
      }
    }
    return false;
  }

  /// Retorna o humor de hoje (se existir)
  String? humorDeHoje(String utilizadorId) {
    final agora = DateTime.now();
    for (var entrada in _humores) {
      if (entrada.utilizadorId == utilizadorId &&
          entrada.dataHora.year == agora.year &&
          entrada.dataHora.month == agora.month &&
          entrada.dataHora.day == agora.day) {
        return entrada.humor;
      }
    }
    return null;
  }

  // Carrega os humores de um utilizador e atualiza a interface via Stream
  void ouvirHumores(String utilizadorId) {
    _servicoBancoDados.streamHumores(utilizadorId).listen((dados) {
      _humores = dados;
      notifyListeners();
    });
  }

  Future<bool> registrarHumor(String utilizadorId, String humor, String? fotoUrl) async {
    // Bloqueia se já registou hoje
    if (jaRegistrouHoje(utilizadorId)) {
      return false;
    }

    _setCarregando(true);
    try {
      final novaEntrada = EntradaHumor(
        id: '', // Gerado pelo Firestore
        utilizadorId: utilizadorId,
        humor: humor,
        dataHora: DateTime.now(),
        fotoUrl: fotoUrl,
      );
      await _servicoBancoDados.adicionarEntradaHumor(novaEntrada);

      // Atualiza o humor atual no perfil do utilizador
      await _servicoBancoDados.atualizarUtilizador(utilizadorId, {
        'humorAtual': humor,
      });

      _setCarregando(false);
      return true;
    } catch (e) {
      debugPrint('Erro ao registrar humor: $e');
    }
    _setCarregando(false);
    return false;
  }

  void _setCarregando(bool valor) {
    _carregando = valor;
    notifyListeners();
  }
}
