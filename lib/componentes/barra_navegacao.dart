import 'package:flutter/material.dart';
import 'tema.dart';

class BarraNavegacao extends StatelessWidget {
  final int indiceAtual;
  final Function(int) aoMudarAba;

  const BarraNavegacao({
    super.key,
    required this.indiceAtual,
    required this.aoMudarAba,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ItemNavegacao(
                icone: Icons.home_filled,
                rotulo: 'Início',
                ativo: indiceAtual == 0,
                aoPressionar: () => aoMudarAba(0),
              ),
              _ItemNavegacao(
                icone: Icons.camera_alt,
                rotulo: 'Escanear',
                ativo: indiceAtual == 1,
                aoPressionar: () => aoMudarAba(1),
              ),
              _ItemNavegacao(
                icone: Icons.bar_chart,
                rotulo: 'Insights',
                ativo: indiceAtual == 2,
                aoPressionar: () => aoMudarAba(2),
              ),
              _ItemNavegacao(
                icone: Icons.forum,
                rotulo: 'Chat',
                ativo: indiceAtual == 3,
                aoPressionar: () => aoMudarAba(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemNavegacao extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final bool ativo;
  final VoidCallback aoPressionar;

  const _ItemNavegacao({
    required this.icone,
    required this.rotulo,
    required this.ativo,
    required this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoPressionar,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: ativo ? TemaMoodi.primarioContainer.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              color: ativo ? TemaMoodi.primarioContainer : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              rotulo,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ativo ? TemaMoodi.primarioContainer : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
