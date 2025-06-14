import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/conch_vm.dart';
import '../widgets/conch_display.dart';
import '../widgets/conch_button.dart';
import '../widgets/conch_navbar.dart';
import '../widgets/instructional_text.dart';

class ConchHomePage extends StatelessWidget {
  const ConchHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ConchViewModel>();
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        centerTitle: true,
        title: const Text('TheConch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const InstructionalText(),
            const ConchDisplay(),
            ConchButton(onPressed: viewModel.generateAnswer),
          ],
        ),
      ),
      bottomNavigationBar: const ConchNavigationBar(),
    );
  }
}