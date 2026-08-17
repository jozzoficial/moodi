import 'package:flutter/material.dart';
import 'tema.dart';

class CampoTexto extends StatelessWidget {
  final String rotulo;
  final String dica;
  final IconData icone;
  final bool ocultarTexto;
  final TextEditingController controlador;
  final TextInputType tipoTeclado;
  final Widget? sufixo;

  const CampoTexto({
    super.key,
    required this.rotulo,
    required this.dica,
    required this.icone,
    required this.controlador,
    this.ocultarTexto = false,
    this.tipoTeclado = TextInputType.text,
    this.sufixo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Text(
            rotulo,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: TemaMoodi.contorno,
                ),
          ),
        ),
        Container(
          height: 56, // h-14
          decoration: BoxDecoration(
            color: TemaMoodi.superficieBaixa,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: Colors.transparent, width: 2),
          ),
          child: TextField(
            controller: controlador,
            obscureText: ocultarTexto,
            keyboardType: tipoTeclado,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: dica,
              hintStyle: TextStyle(color: TemaMoodi.contornoVariante),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              suffixIcon: sufixo ?? Icon(icone, color: TemaMoodi.contornoVariante),
            ),
          ),
        ),
      ],
    );
  }
}
