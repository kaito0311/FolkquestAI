import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xffd7b66f),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.08,
        ),
      ),
    );
  }
}
