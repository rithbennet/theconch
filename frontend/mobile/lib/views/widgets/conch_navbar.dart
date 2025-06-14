import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/conch_vm.dart';

class ConchNavigationBar extends StatelessWidget {
  const ConchNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConchViewModel>(
      builder: (context, viewModel, child) {
        return NavigationBar(
          backgroundColor: const Color(0xFF1B263B),
          selectedIndex: viewModel.currentIndex,
          onDestinationSelected: viewModel.updateIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        );
      },
    );
  }
}