import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../modelos/utilizador.dart';

class ServicoAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obter o utilizador atual
  User? get utilizadorAtual => _auth.currentUser;

  // Stream de mudança de estado de autenticação
  Stream<User?> get estadoAuth => _auth.authStateChanges();

  // Registro com E-mail, Senha e Codinome
  Future<Utilizador?> registrarComEmailSenha(String email, String senha, String codinome) async {
    try {
      UserCredential resultado = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      
      User? usuarioFirebase = resultado.user;
      
      if (usuarioFirebase != null) {
        // Atualiza o perfil com o codinome
        await usuarioFirebase.updateDisplayName(codinome);
        await usuarioFirebase.reload();
        
        return Utilizador(
          id: usuarioFirebase.uid,
          codinome: codinome,
          email: email,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao registrar: $e');
      rethrow;
    }
  }

  // Login com E-mail e Senha
  Future<Utilizador?> entrarComEmailSenha(String email, String senha) async {
    try {
      UserCredential resultado = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha, // A propriedade é password no FirebaseAuth
      );
      
      User? usuarioFirebase = resultado.user;
      
      if (usuarioFirebase != null) {
        return Utilizador(
          id: usuarioFirebase.uid,
          codinome: usuarioFirebase.displayName ?? 'Anônimo',
          email: usuarioFirebase.email ?? email,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao entrar: $e');
      rethrow;
    }
  }

  // Login com Google
  Future<Utilizador?> entrarComGoogle() async {
    try {
      final GoogleSignInAccount? contaGoogle = await GoogleSignIn().signIn();
      if (contaGoogle == null) {
        // Usuário cancelou o login
        return null;
      }

      final GoogleSignInAuthentication authGoogle = await contaGoogle.authentication;

      final AuthCredential credencial = GoogleAuthProvider.credential(
        accessToken: authGoogle.accessToken,
        idToken: authGoogle.idToken,
      );

      final UserCredential resultado = await _auth.signInWithCredential(credencial);
      final User? usuarioFirebase = resultado.user;

      if (usuarioFirebase != null) {
        return Utilizador(
          id: usuarioFirebase.uid,
          codinome: usuarioFirebase.displayName ?? 'Anônimo',
          email: usuarioFirebase.email ?? '',
        );
      }
      return null;
    } catch (e) {
      debugPrint('Erro no login com Google: $e');
      rethrow;
    }
  }

  // Sair da conta
  Future<void> sair() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Erro ao sair: $e');
      rethrow;
    }
  }
}
