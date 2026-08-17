import 'package:flutter/material.dart';
import '../componentes/tema.dart';
import 'tela_chat.dart';

class TelaComunidade extends StatelessWidget {
  const TelaComunidade({super.key});

  @override
  Widget build(BuildContext context) {
    // Salas fictícias para exemplo
    final salas = [
      {'id': 'sala_feliz', 'nome': 'Sala da Alegria', 'humor': 'Feliz', 'cor': TemaMoodi.primarioContainer},
      {'id': 'sala_triste', 'nome': 'Ombro Amigo', 'humor': 'Triste', 'cor': TemaMoodi.contorno},
      {'id': 'sala_ansioso', 'nome': 'Respira Fundo', 'humor': 'Ansioso', 'cor': TemaMoodi.secundario},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TemaMoodi.contorno),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Comunidade',
          style: TextStyle(
            color: TemaMoodi.noFundo,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: salas.length,
        itemBuilder: (context, index) {
          final sala = salas[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            color: (sala['cor'] as Color).withValues(alpha: 0.1),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: sala['cor'] as Color,
                child: const Icon(Icons.group, color: Colors.white),
              ),
              title: Text(
                sala['nome'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Baseado no humor: ${sala['humor']}'),
              trailing: const Icon(Icons.chat_bubble_outline),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TelaChat(
                      salaId: sala['id'] as String,
                      nomeSala: sala['nome'] as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
