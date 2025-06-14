import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/conch_vm.dart';

class ConchDisplay extends StatelessWidget {
  const ConchDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConchViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1B263B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            viewModel.currentAnswer,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 36,
              color: const Color(0xFFFF6B6B),
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}