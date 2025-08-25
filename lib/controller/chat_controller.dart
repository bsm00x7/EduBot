import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:ai_chat/config/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/message.dart';

// Message model for better data structure


class ChatController with ChangeNotifier {
  // Using Message objects instead of plain strings
  List<Message> messages = [
    Message(
      content: "Hi there! I'm EduBot, your AI-powered study assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.system,
    )
  ];

  bool isLoading = false;
  bool _isGeminiInitialized = false;
  final TextEditingController controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Timeout duration for requests
  static const Duration _requestTimeout = Duration(seconds: 30);

  ChatController() {
    _initializeGemini();
  }

  // Initialize Gemini with API key from environment variables
  void _initializeGemini() {
    try {
      // Get API key from environment variables or secure storage
      const apiKey = AppConfig.geminiApiKey;

      if (apiKey.isEmpty) {
        debugPrint('Warning: GEMINI_API_KEY not found in environment variables');
        // For development/testing purposes, you can temporarily use your API key here
        // IMPORTANT: Remove this before committing to version control!
        const fallbackApiKey = 'AIzaSyAPw_uTorkc1PLIbAwiKOjK_yUK8UjXRWo'; // Your API key

        if (fallbackApiKey.isNotEmpty) {
          Gemini.init(apiKey: fallbackApiKey);
          debugPrint('Warning: Using fallback API key. Please set GEMINI_API_KEY environment variable.');
        } else {
          _isGeminiInitialized = false;
          return;
        }
      } else {
        Gemini.init(apiKey: apiKey);
      }

      _isGeminiInitialized = true;
    } catch (e) {
      debugPrint('Error initializing Gemini: $e');
      _isGeminiInitialized = false;
    }
  }

  // Send text message
  Future<void> sendRequest() async {
    final userMessage = controller.text.trim();

    // Validate input
    if (userMessage.isEmpty) return;

    // Check if Gemini is initialized
    if (!_isGeminiInitialized) {
      _addErrorMessage('AI service is not available. Please check your configuration and restart the app.');
      return;
    }

    // Add user message
    _addUserMessage(userMessage);
    _setLoadingState(true);
    controller.clear();

    try {
      // Send request with timeout
      final response = await Gemini.instance
          .text(userMessage)
          .timeout(_requestTimeout);

      final botResponse = response?.output?.trim();

      if (botResponse == null || botResponse.isEmpty) {
        throw Exception('Empty response received from AI service');
      }

      _addBotMessage(botResponse);

    } on TimeoutException {
      _addErrorMessage("Request timed out. Please try again.");
    } on SocketException {
      _addErrorMessage("No internet connection. Please check your network and try again.");
    } on HttpException {
      _addErrorMessage("Server error. Please try again later.");
    } catch (e) {
      debugPrint('Error sending request: $e');
      if (e.toString().contains('LateInitializationError')) {
        _addErrorMessage("AI service initialization failed. Please restart the app.");
      } else {
        _addErrorMessage("Sorry, I'm experiencing technical difficulties. Please try again later.");
      }
    } finally {
      _setLoadingState(false);
    }
  }

  // Send image with optional text
  Future<void> sendRequestImageText({ImageSource source = ImageSource.gallery}) async {
    try {
      // Check if Gemini is initialized
      if (!_isGeminiInitialized) {
        _addErrorMessage('AI service is not available. Please check your configuration and restart the app.');
        return;
      }

      // Check and request permission
      final permissionStatus = await _requestPhotoPermission();
      if (!permissionStatus) {
        _addErrorMessage("Photo permission is required to process images.");
        return;
      }

      // Pick image
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compress image to reduce processing time
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) {
        // User cancelled image selection
        return;
      }

      // Get user text or use default
      final userText = controller.text.trim().isEmpty
          ? "What is this picture?"
          : controller.text.trim();

      // Add user message with image
      _addUserMessage(userText, MessageType.image, image.path);
      _setLoadingState(true);
      controller.clear();

      // Process image
      final file = File(image.path);

      // Validate file exists and is readable
      if (!await file.exists()) {
        throw Exception('Selected image file not found');
      }

      final imageBytes = await file.readAsBytes();

      // Send request with timeout
      final response = await Gemini.instance
          .textAndImage(
        text: userText,
        images: [imageBytes],
      )
          .timeout(_requestTimeout);

      final botResponse = response?.output?.trim();

      if (botResponse == null || botResponse.isEmpty) {
        throw Exception('Empty response received from AI service');
      }

      _addBotMessage(botResponse);

    } on TimeoutException {
      _addErrorMessage("Image processing timed out. Please try with a smaller image.");
    } on SocketException {
      _addErrorMessage("No internet connection. Please check your network and try again.");
    } on FileSystemException {
      _addErrorMessage("Error reading the selected image. Please try another image.");
    } catch (e) {
      debugPrint('Error processing image: $e');
      if (e.toString().contains('LateInitializationError')) {
        _addErrorMessage("AI service initialization failed. Please restart the app.");
      } else {
        _addErrorMessage("Sorry, I couldn't process the image. Please try again.");
      }
    } finally {
      _setLoadingState(false);
    }
  }

  // Request photo permission
  Future<bool> _requestPhotoPermission() async {
    try {
      PermissionStatus status = await Permission.photos.request();

      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        debugPrint("Photo permission denied");
        return false;
      } else if (status.isPermanentlyDenied) {
        debugPrint("Photo permission permanently denied");
        // You might want to show a dialog to open app settings
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('Error requesting photo permission: $e');
      return false;
    }
  }

  // Helper methods for adding messages
  void _addUserMessage(String content, [MessageType type = MessageType.text, String? imagePath]) {
    messages.add(Message(
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      type: type,
      imagePath: imagePath,
    ));
    notifyListeners();
  }

  void _addBotMessage(String content, [MessageType type = MessageType.text]) {
    messages.add(Message(
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      type: type,
    ));
    notifyListeners();
  }

  void _addErrorMessage(String content) {
    messages.add(Message(
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.error,
    ));
    notifyListeners();
  }

  void _setLoadingState(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  // Method to clear chat history
  void clearChat() {
    messages = [
      Message(
        content: "Hi there! I'm EduBot, your AI-powered study assistant. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.system,
      )
    ];
    notifyListeners();
  }

  // Method to delete a specific message
  void deleteMessage(int index) {
    if (index >= 0 && index < messages.length && index != 0) { // Don't delete welcome message
      messages.removeAt(index);
      notifyListeners();
    }
  }

  // Utility getters
  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;

  bool get isChatEmpty => messages.length <= 1;

  int get messageCount => messages.length;

  List<Message> get userMessages => messages.where((msg) => msg.isUser).toList();

  List<Message> get botMessages => messages.where((msg) => !msg.isUser).toList();

  bool get isProcessing => isLoading;

  // Get conversation history as formatted string (useful for exporting)
  String get conversationHistory {
    return messages
        .where((msg) => msg.type != MessageType.system)
        .map((msg) => '${msg.isUser ? "User" : "EduBot"} (${msg.timestamp.toString().split('.')[0]}): ${msg.content}')
        .join('\n---\n');
  }

  // Search through messages
  List<Message> searchMessages(String query) {
    final lowercaseQuery = query.toLowerCase();
    return messages
        .where((msg) => msg.content.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Get messages by date range
  List<Message> getMessagesByDateRange(DateTime start, DateTime end) {
    return messages
        .where((msg) =>
    msg.timestamp.isAfter(start) &&
        msg.timestamp.isBefore(end))
        .toList();
  }

  // Export chat as JSON (useful for backup/sharing)
  Map<String, dynamic> exportChatAsJson() {
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'messageCount': messages.length,
      'messages': messages.map((msg) => {
        'content': msg.content,
        'isUser': msg.isUser,
        'timestamp': msg.timestamp.toIso8601String(),
        'type': msg.type.toString(),
        'imagePath': msg.imagePath,
      }).toList(),
    };
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}