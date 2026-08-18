import 'dart:async';
import 'package:flutter/material.dart';
import '../modelos/utilizador.dart';
import '../servicos/servico_auth.dart';
import '../servicos/servico_banco_dados.dart';

class ControladorAuth extends ChangeNotifier {
  final ServicoAuth _servicoAuth = ServicoAuth();
  final ServicoBancoDados _servicoBancoDados = ServicoBancoDados();

  Utilizador? _utilizadorAtual;
  bool _carregando = false;
  bool _precisaCodinome = false;
  StreamSubscription? _authSubscription;

  Utilizador? get utilizadorAtual => _utilizadorAtual;
  bool get carregando => _carregando;
  bool get precisaCodinome => _precisaCodinome;

  ControladorAuth() {
    _inicializar();
  }

  void _inicializar() {
    _authSubscription = _servicoAuth.estadoAuth.listen((user) async {
      if (user != null) {
        // Tenta buscar do Firestore, se não existir cria um fallback
        Utilizador? utilizadorFirestore =
            await _servicoBancoDados.obterUtilizador(user.uid);
        if (utilizadorFirestore != null) {
          _utilizadorAtual = utilizadorFirestore;
          _precisaCodinome = false;
        } else {
          // Fallback: cria utilizador a partir dos dados do Firebase Auth
          _utilizadorAtual = Utilizador(
            id: user.uid,
            codinome: user.displayName ?? 'Anônimo',
            email: user.email ?? '',
            dataCriacao: DateTime.now(),
          );
          // Salva no Firestore para futuras consultas
          await _servicoBancoDados.salvarUtilizador(_utilizadorAtual!);
        }
      } else {
        _utilizadorAtual = null;
        _precisaCodinome = false;
      }
      notifyListeners();
    });
  }

  Future<bool> registrar(String email, String senha, String codinome) async {
    _setCarregando(true);
    try {
      Utilizador? novoUtilizador =
          await _servicoAuth.registrarComEmailSenha(email, senha, codinome);
      if (novoUtilizador != null) {
        final utilizadorCompleto = Utilizador(
          id: novoUtilizador.id,
          codinome: codinome,
          email: email,
          dataCriacao: DateTime.now(),
        );
        await _servicoBancoDados.salvarUtilizador(utilizadorCompleto);
        _utilizadorAtual = utilizadorCompleto;
        _setCarregando(false);
        return true;
      }
    } catch (e) {
      debugPrint('Erro no ControladorAuth.registrar: $e');
    }
    _setCarregando(false);
    return false;
  }

  Future<bool> entrar(String email, String senha) async {
    _setCarregando(true);
    try {
      Utilizador? utilizador =
          await _servicoAuth.entrarComEmailSenha(email, senha);
      if (utilizador != null) {
        Utilizador? utilizadorFirestore =
            await _servicoBancoDados.obterUtilizador(utilizador.id);
        _utilizadorAtual = utilizadorFirestore ?? utilizador;
        _setCarregando(false);
        return true;
      }
    } catch (e) {
      debugPrint('Erro no ControladorAuth.entrar: $e');
    }
    _setCarregando(false);
    return false;
  }

  Future<bool> entrarComGoogle() async {
    _setCarregando(true);
    try {
      Utilizador? utilizador = await _servicoAuth.entrarComGoogle();
      if (utilizador != null) {
        Utilizador? utilizadorFirestore =
            await _servicoBancoDados.obterUtilizador(utilizador.id);
            
        if (utilizadorFirestore == null) {
          // Primeira vez — precisa escolher codinome
          _utilizadorAtual = Utilizador(
            id: utilizador.id,
            codinome: utilizador.codinome,
            email: utilizador.email,
            dataCriacao: DateTime.now(),
          );
          await _servicoBancoDados.salvarUtilizador(_utilizadorAtual!);
          _precisaCodinome = true;
        } else {
          _utilizadorAtual = utilizadorFirestore;
          _precisaCodinome = false;
        }
        
        _setCarregando(false);
        return true;
      }
    } catch (e) {
      debugPrint('Erro no ControladorAuth.entrarComGoogle: $e');
    }
    _setCarregando(false);
    return false;
  }

  Future<void> atualizarPerfil({String? codinome, String? bio}) async {
    if (_utilizadorAtual == null) return;
    
    final dados = <String, dynamic>{};
    if (codinome != null) dados['codinome'] = codinome;
    if (bio != null) dados['bio'] = bio;
    
    if (dados.isEmpty) return;

    await _servicoBancoDados.atualizarUtilizador(_utilizadorAtual!.id, dados);
    
    _utilizadorAtual = _utilizadorAtual!.copiarCom(
      codinome: codinome,
      bio: bio,
    );
    _precisaCodinome = false;
    notifyListeners();
  }

  Future<void> sair() async {
    await _servicoAuth.sair();
    _utilizadorAtual = null;
    _precisaCodinome = false;
    notifyListeners();
  }

  void _setCarregando(bool valor) {
    _carregando = valor;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
