import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../modelos/publicacao.dart';
import '../modelos/comentario.dart';
import '../servicos/servico_banco_dados.dart';

class ControladorComunidade extends ChangeNotifier {
  final ServicoBancoDados _servicoBancoDados = ServicoBancoDados();

  List<Publicacao> _publicacoes = [];
  String _humorFiltro = 'Feliz';
  bool _carregando = false;

  List<Publicacao> get publicacoes => _publicacoes;
  String get humorFiltro => _humorFiltro;
  bool get carregando => _carregando;

  /// Começa a ouvir publicações filtradas por humor
  void ouvirPublicacoes(String humor) {
    _humorFiltro = humor;
    notifyListeners();
    
    _servicoBancoDados.streamPublicacoes(humor).listen((dados) {
      _publicacoes = dados;
      notifyListeners();
    });
  }

  /// Muda o filtro de humor
  void mudarFiltro(String humor) {
    ouvirPublicacoes(humor);
  }

  /// Cria uma nova publicação
  Future<void> criarPublicacao({
    required String autorId,
    required String autorCodinome,
    required String humor,
    required String texto,
  }) async {
    _setCarregando(true);
    try {
      final publicacao = Publicacao(
        id: '',
        autorId: autorId,
        autorCodinome: autorCodinome,
        humor: humor,
        texto: texto,
        dataHora: DateTime.now(),
      );
      await _servicoBancoDados.criarPublicacao(publicacao);
    } catch (e) {
      debugPrint('Erro ao criar publicação: $e');
    }
    _setCarregando(false);
  }

  /// Toggle like numa publicação
  Future<void> toggleLike(String publicacaoId, String uid) async {
    try {
      await _servicoBancoDados.darLike(publicacaoId, uid);
    } catch (e) {
      debugPrint('Erro ao dar like: $e');
    }
  }

  /// Stream de comentários de uma publicação
  Stream<List<Comentario>> streamComentarios(String publicacaoId) {
    return _servicoBancoDados.streamComentarios(publicacaoId);
  }

  /// Adiciona um comentário a uma publicação
  Future<void> comentar({
    required String publicacaoId,
    required String autorId,
    required String autorCodinome,
    required String texto,
  }) async {
    try {
      final comentario = Comentario(
        id: '',
        autorId: autorId,
        autorCodinome: autorCodinome,
        texto: texto,
        dataHora: DateTime.now(),
      );
      await _servicoBancoDados.adicionarComentario(publicacaoId, comentario);
    } catch (e) {
      debugPrint('Erro ao comentar: $e');
    }
  }

  void _setCarregando(bool valor) {
    _carregando = valor;
    notifyListeners();
  }
}
