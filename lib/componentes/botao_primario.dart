import 'package:flutter/material.dart';
import 'tema.dart';

class BotaoPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback aoPressionar;
  final IconData? icone;
  final bool carregando;

  const BotaoPrimario({
    super.key,
    required this.texto,
    required this.aoPressionar,
    this.icone,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56, // h-14
      decoration: BoxDecoration(
        color: TemaMoodi.primarioContainer,
        borderRadius: BorderRadius.circular(9999), // rounded-full
        boxShadow: [
          BoxShadow(
            color: TemaMoodi.primarioContainer.withValues(alpha: 0.4),
            blurRadius: 25,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(9999),
          onTap: carregando ? null : aoPressionar,
          child: Center(
            child: carregando
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icone != null) ...[
                        Icon(icone, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        texto,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
