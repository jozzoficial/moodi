import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'componentes/tema.dart';
import 'controladores/controlador_auth.dart';
import 'controladores/controlador_humor.dart';
import 'controladores/controlador_chat.dart';
import 'telas/tela_login.dart';
import 'telas/tela_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Aviso: Falha ao carregar o ficheiro .env: $e");
  }
  
  // Tenta inicializar o Firebase. 
  // Nota: o usuário precisa rodar `flutterfire configure` para gerar o `firebase_options.dart`
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Ativa o App Check — necessário para o Firebase AI Logic funcionar
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      // Na Web, usa o modo debug durante o desenvolvimento
      webProvider: kDebugMode
          ? ReCaptchaV3Provider('debug')
          : ReCaptchaV3Provider('debug'),
    );
  } catch (e) {
    debugPrint("Aviso: Firebase não configurado. Rode 'flutterfire configure'. Erro: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ControladorAuth()),
        ChangeNotifierProvider(create: (_) => ControladorHumor()),
        ChangeNotifierProvider(create: (_) => ControladorChat()),
      ],
      child: const MoodiApp(),
    ),
  );
}

class MoodiApp extends StatelessWidget {
  const MoodiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood¡',
      debugShowCheckedModeBanner: false,
      theme: TemaMoodi.temaClaro,
      home: const WrapperAutenticacao(),
    );
  }
}

class WrapperAutenticacao extends StatelessWidget {
  const WrapperAutenticacao({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ControladorAuth>();
    
    // Se estiver carregando, mostra tela em branco
    if (auth.carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Direciona para Dashboard se autenticado, senão Login
    if (auth.utilizadorAtual != null) {
      return const TelaDashboard();
    } else {
      return const TelaLogin();
    }
  }
}
