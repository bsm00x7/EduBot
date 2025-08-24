import 'package:flutter/cupertino.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatController with ChangeNotifier {
  List<String> questionReponse = [
    "Hi there! I'm EduBot, your AI-powered study assistant. How can I help you today?"
  ];

  bool isloading = false;
  TextEditingController controller = TextEditingController();

  ChatController() {
    Gemini.init(apiKey: 'AIzaSyAPw_uTorkc1PLIbAwiKOjK_yUK8UjXRWo');
  }

  Future<void> sendRequest() async {
    final userMessage = controller.text.trim();

    // Validate input
    if (userMessage.isEmpty) return;

    // Add user message and set loading state
    questionReponse.add(userMessage);
    isloading = true;
    controller.clear();
    notifyListeners();

    try {
      final response = await Gemini.instance.text(userMessage);

      // Add bot response
      final botResponse = response?.output?.trim() ?? "Sorry, I couldn't process your request. Please try again.";
      questionReponse.add(botResponse);

      print('Bot response: $botResponse');

    } catch (e) {
      debugPrint('Error sending request: $e');

      // Add error message for user
      questionReponse.add("Sorry, I'm having trouble connecting right now. Please check your internet connection and try again.");

    } finally {
      isloading = false;
      notifyListeners();
    }
  }

  // Method to clear chat history
  void clearChat() {
    questionReponse = [
      "Hi there! I'm EduBot, your AI-powered study assistant. How can I help you today?"
    ];
    notifyListeners();
  }

  // Method to get the last message
  String? getLastMessage() {
    return questionReponse.isNotEmpty ? questionReponse.last : null;
  }

  // Method to check if chat is empty (only has welcome message)
  bool get isChatEmpty => questionReponse.length <= 1;

  // Method to get message count
  int get messageCount => questionReponse.length;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}