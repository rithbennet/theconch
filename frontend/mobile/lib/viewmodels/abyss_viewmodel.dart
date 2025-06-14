import 'package:flutter/material.dart';
import '../api_service.dart';

class AbyssViewModel extends ChangeNotifier {
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;
  String abyssResponse = 'Ask your question...';
  String? errorMessage;

  Future<void> askAbyss() async {
    if (controller.text.trim().isEmpty) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await ApiService.askAbyss(controller.text.trim());
      abyssResponse = result['answer'] ?? '...';
    } catch (e) {
      abyssResponse = 'Error!';
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
