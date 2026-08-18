import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/utilizador.dart';
import '../modelos/entrada_humor.dart';
import '../modelos/mensagem.dart';
import '../modelos/publicacao.dart';
import '../modelos/comentario.dart';
import '../modelos/conversa_privada.dart';

class ServicoBancoDados {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ──────────────────────────────────────────
  // UTILIZADORES
  // ──────────────────────────────────────────

  Future<void> salvarUtilizador(Utilizador utilizador) async {
    await _firestore
        .collection('utilizadores')
        .doc(utilizador.id)
        .set(utilizador.paraMapa());
  }

  Future<Utilizador?> obterUtilizador(String id) async {
    DocumentSnapshot doc = await _firestore.collection('utilizadores').doc(id).get();
    if (doc.exists) {
      return Utilizador.deMapa(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> atualizarUtilizador(String id, Map<String, dynamic> dados) async {
    await _firestore.collection('utilizadores').doc(id).update(dados);
  }

  // ──────────────────────────────────────────
  // HUMOR
  // ──────────────────────────────────────────

  Future<void> adicionarEntradaHumor(EntradaHumor entrada) async {
    await _firestore.collection('humores').add(entrada.paraMapa());
  }

  Future<void> atualizarEntradaHumor(String id, EntradaHumor entrada) async {
    await _firestore.collection('humores').doc(id).update(entrada.paraMapa());
  }

  Stream<List<EntradaHumor>> streamHumores(String utilizadorId) {
    return _firestore
        .collection('humores')
        .where('utilizadorId', isEqualTo: utilizadorId)
        .orderBy('dataHora', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EntradaHumor.deMapa(doc.data(), doc.id))
            .toList());
  }

  // ──────────────────────────────────────────
  // PUBLICAÇÕES (COMUNIDADE)
  // ──────────────────────────────────────────

  Future<void> criarPublicacao(Publicacao publicacao) async {
    await _firestore.collection('publicacoes').add(publicacao.paraMapa());
  }

  Stream<List<Publicacao>> streamPublicacoes(String humor) {
    return _firestore
        .collection('publicacoes')
        .where('humor', isEqualTo: humor)
        .orderBy('dataHora', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Publicacao.deMapa(doc.data(), doc.id))
            .toList());
  }

  Future<void> darLike(String publicacaoId, String uid) async {
    final ref = _firestore.collection('publicacoes').doc(publicacaoId);
    final doc = await ref.get();
    if (!doc.exists) return;

    final likesUids = List<String>.from(doc.data()?['likesUids'] ?? []);
    
    if (likesUids.contains(uid)) {
      // Remove o like
      likesUids.remove(uid);
      await ref.update({
        'likesUids': likesUids,
        'totalLikes': FieldValue.increment(-1),
      });
    } else {
      // Adiciona o like
      likesUids.add(uid);
      await ref.update({
        'likesUids': likesUids,
        'totalLikes': FieldValue.increment(1),
      });
    }
  }

  // ──────────────────────────────────────────
  // COMENTÁRIOS
  // ──────────────────────────────────────────

  Stream<List<Comentario>> streamComentarios(String publicacaoId) {
    return _firestore
        .collection('publicacoes')
        .doc(publicacaoId)
        .collection('comentarios')
        .orderBy('dataHora', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comentario.deMapa(doc.data(), doc.id))
            .toList());
  }

  Future<void> adicionarComentario(String publicacaoId, Comentario comentario) async {
    await _firestore
        .collection('publicacoes')
        .doc(publicacaoId)
        .collection('comentarios')
        .add(comentario.paraMapa());
    
    // Incrementa o contador de comentários na publicação
    await _firestore
        .collection('publicacoes')
        .doc(publicacaoId)
        .update({'totalComentarios': FieldValue.increment(1)});
  }

  // ──────────────────────────────────────────
  // CHAT (SALAS DE COMUNIDADE — legado)
  // ──────────────────────────────────────────

  Future<void> enviarMensagem(String salaId, Mensagem mensagem) async {
    await _firestore
        .collection('salas')
        .doc(salaId)
        .collection('mensagens')
        .add(mensagem.paraMapa());
  }

  Stream<List<Mensagem>> streamMensagens(String salaId) {
    return _firestore
        .collection('salas')
        .doc(salaId)
        .collection('mensagens')
        .orderBy('dataHora', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Mensagem.deMapa(doc.data(), doc.id))
            .toList());
  }

  // ──────────────────────────────────────────
  // MENSAGENS PRIVADAS
  // ──────────────────────────────────────────

  /// Gera um ID de conversa determinístico a partir de dois UIDs
  String _gerarConversaId(String uid1, String uid2) {
    final uids = [uid1, uid2]..sort();
    return '${uids[0]}_${uids[1]}';
  }

  Future<ConversaPrivada> criarOuObterConversa(
    String uid1, String uid2,
    String codinome1, String codinome2,
  ) async {
    final conversaId = _gerarConversaId(uid1, uid2);
    final ref = _firestore.collection('conversas_privadas').doc(conversaId);
    final doc = await ref.get();

    if (doc.exists) {
      return ConversaPrivada.deMapa(doc.data()!, doc.id);
    }

    final novaConversa = ConversaPrivada(
      id: conversaId,
      participantes: [uid1, uid2],
      ultimaMensagem: '',
      dataUltimaMensagem: DateTime.now(),
      codinomes: {uid1: codinome1, uid2: codinome2},
    );

    await ref.set(novaConversa.paraMapa());
    return novaConversa;
  }

  Stream<List<ConversaPrivada>> streamConversas(String uid) {
    return _firestore
        .collection('conversas_privadas')
        .where('participantes', arrayContains: uid)
        .orderBy('dataUltimaMensagem', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversaPrivada.deMapa(doc.data(), doc.id))
            .toList());
  }

  Future<void> enviarMensagemPrivada(String conversaId, Mensagem mensagem) async {
    // Adiciona a mensagem
    await _firestore
        .collection('conversas_privadas')
        .doc(conversaId)
        .collection('mensagens')
        .add(mensagem.paraMapa());

    // Atualiza a última mensagem na conversa
    await _firestore
        .collection('conversas_privadas')
        .doc(conversaId)
        .update({
      'ultimaMensagem': mensagem.texto,
      'dataUltimaMensagem': mensagem.dataHora.toIso8601String(),
    });
  }

  Stream<List<Mensagem>> streamMensagensPrivadas(String conversaId) {
    return _firestore
        .collection('conversas_privadas')
        .doc(conversaId)
        .collection('mensagens')
        .orderBy('dataHora', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Mensagem.deMapa(doc.data(), doc.id))
            .toList());
  }

  /// Apaga mensagens expiradas (>7 dias) numa conversa
  Future<void> limparMensagensExpiradas(String conversaId) async {
    final agora = DateTime.now();
    final snapshot = await _firestore
        .collection('conversas_privadas')
        .doc(conversaId)
        .collection('mensagens')
        .get();

    final batch = _firestore.batch();
    int apagadas = 0;

    for (var doc in snapshot.docs) {
      final expiraEmStr = doc.data()['expiraEm'];
      if (expiraEmStr != null) {
        final expiraEm = DateTime.parse(expiraEmStr);
        if (agora.isAfter(expiraEm)) {
          batch.delete(doc.reference);
          apagadas++;
        }
      }
    }

    if (apagadas > 0) {
      await batch.commit();
    }
  }
}
