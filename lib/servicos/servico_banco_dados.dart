import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/utilizador.dart';
import '../modelos/entrada_humor.dart';
import '../modelos/mensagem.dart';

class ServicoBancoDados {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Utilizadores ---
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

  // --- Humor ---
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

  // --- Chat ---
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
}
