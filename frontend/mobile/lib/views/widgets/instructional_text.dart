import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InstructionalText extends StatelessWidget {
  const InstructionalText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Ask a question and shake your phone\nor tap the button below',
      style: GoogleFonts.poppins(
        fontSize: 18,
        color: Colors.white70,
      ),
      textAlign: TextAlign.center,
    );
  }
}