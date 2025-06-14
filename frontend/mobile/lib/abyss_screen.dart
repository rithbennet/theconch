import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'viewmodels/abyss_viewmodel.dart';

class AbyssScreen extends StatelessWidget {
  const AbyssScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AbyssViewModel(),
      child: Consumer<AbyssViewModel>(
        builder: (context, vm, child) => Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D1B2A),
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Ask the Abyss',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                color: const Color(0xFFF0F0F0),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Peer into the unknown. Ask anything.',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFFA0AEC0),
                  ),
                  textAlign: TextAlign.center,
                ),
                Column(
                  children: [
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(125),
                        color: const Color(0xFF1B263B),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.psychology,
                              size: 80,
                              color: const Color(0xFFFF6B6B),
                            ),
                            const SizedBox(height: 8),
                            Text('🌊', style: const TextStyle(fontSize: 60)),
                            const SizedBox(height: 8),
                            Text(
                              'The Abyss',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFA0AEC0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: vm.controller,
                      enabled: !vm.isLoading,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: const Color(0xFFF0F0F0),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type your question...',
                        hintStyle: GoogleFonts.poppins(color: const Color(0xFFA0AEC0)),
                        filled: true,
                        fillColor: const Color(0xFF1B263B),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onSubmitted: (_) => vm.askAbyss(),
                    ),
                    const SizedBox(height: 24),
                    vm.isLoading
                        ? const CircularProgressIndicator(color: Color(0xFFFF6B6B))
                        : Column(
                            children: [
                              Text(
                                vm.abyssResponse,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: const Color(0xFFFF6B6B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (vm.errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  vm.errorMessage!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                  ],
                ),
                ElevatedButton(
                  onPressed: vm.isLoading ? null : vm.askAbyss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: const Color(0xFF0D1B2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Text(
                      'Ask the Abyss',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
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
