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
  StreamSubscription? _authSubscription;

  Utilizador? get utilizadorAtual => _utilizadorAtual;
  bool get carregando => _carregando;

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
        } else {
          // Fallback: cria utilizador a partir dos dados do Firebase Auth
          _utilizadorAtual = Utilizador(
            id: user.uid,
            codinome: user.displayName ?? 'Anônimo',
            email: user.email ?? '',
          );
          // Salva no Firestore para futuras consultas
          await _servicoBancoDados.salvarUtilizador(_utilizadorAtual!);
        }
      } else {
        _utilizadorAtual = null;
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
        await _servicoBancoDados.salvarUtilizador(novoUtilizador);
        _utilizadorAtual = novoUtilizador;
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
          // Se for a primeira vez, salva no Firestore
          await _servicoBancoDados.salvarUtilizador(utilizador);
        }
        
        _utilizadorAtual = utilizadorFirestore ?? utilizador;
        _setCarregando(false);
        return true;
      }
    } catch (e) {
      debugPrint('Erro no ControladorAuth.entrarComGoogle: $e');
    }
    _setCarregando(false);
    return false;
  }

  Future<void> sair() async {
    await _servicoAuth.sair();
    _utilizadorAtual = null;
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
