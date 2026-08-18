import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ServicoIA {
  final GenerativeModel _modelo;

  ServicoIA()
      : _modelo = GenerativeModel(
          model: 'gemini-3.6-flash',
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
        );

  Future<String?> analisarHumor(Uint8List imageBytes) async {
    try {
      final prompt = TextPart('''
Analise o rosto da pessoa nesta foto e responda APENAS com UMA das seguintes palavras que melhor descreva a emoção dela: 
Feliz, Calmo, Neutro, Ansioso, Triste, Raivoso.

Se não houver nenhum rosto visível, responda "Neutro".
Não inclua nenhuma pontuação ou texto adicional.
''');
      
      final imagePart = DataPart('image/jpeg', imageBytes);

      final resposta = await _modelo.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final texto = resposta.text?.trim() ?? 'Neutro';
      
      // Valida se a resposta está dentro das permitidas
      const permitidos = ['Feliz', 'Calmo', 'Neutro', 'Ansioso', 'Triste', 'Raivoso'];
      if (permitidos.contains(texto)) {
        return texto;
      } else {
        // Se a IA responder algo fora do padrão, tenta achar correspondência
        for (var permitido in permitidos) {
          if (texto.toLowerCase().contains(permitido.toLowerCase())) {
            return permitido;
          }
        }
      }
      return 'Neutro';
    } catch (e) {
      debugPrint('Erro ao analisar humor com Gemini: $e');
      throw Exception('Erro Gemini: $e');
    }
  }
}
