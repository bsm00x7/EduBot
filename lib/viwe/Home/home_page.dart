import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../controller/chat_controller.dart';
import '../../model/message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return ChangeNotifierProvider(
      create: (BuildContext context) => ChatController(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  FontAwesomeIcons.graduationCap,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "EduBot",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            Consumer<ChatController>(
              builder: (context, provider, child) {
                return PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade600,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'clear':
                        _showClearChatDialog(context, provider);
                        break;
                      case 'export':
                        _exportChat(provider);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          const Text('Clear Chat'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          const Text('Export Chat'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey.shade300,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Expanded(
                  child: Consumer<ChatController>(
                    builder: (context, provider, child) {
                      // Auto-scroll when new messages are added
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (provider.messages.isNotEmpty) {
                          _scrollToBottom();
                        }
                      });

                      return provider.messages.length <= 1
                          ? _buildEmptyState(theme, size, provider)
                          : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) {
                          final message = provider.messages[index];
                          if (message.type == MessageType.system && index == 0) {
                            return _buildWelcomeMessage(message, theme);
                          }
                          return provider.isLoading ? _buildChatBubble(context, message, theme, index) : _buildChatBubble(
                            context,
                            message,
                            theme,
                            index,
                          );
                        },
                      );
                    },
                  ),
                ),
                _buildInputSection(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, Size size, ChatController provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.commentDots,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Welcome to EduBot!",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Ask me anything to get started",
            style: GoogleFonts.openSans(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          _buildSuggestionChips(theme, provider),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips(ThemeData theme, ChatController provider) {
    final suggestions = [
      "Explain quantum physics",
      "Help with math homework",
      "Study tips",
      "Science facts",
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((suggestion) {
        return InkWell(
          onTap: () {
            provider.controller.text = suggestion;
            provider.sendRequest();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              suggestion,
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWelcomeMessage(Message message, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.robot,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message.content,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(
      BuildContext context,
      Message message,
      ThemeData theme,
      int index,
      ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: message.isUser
                  ? _buildUserMessage(message, theme)
                  : _buildBotMessage(message, theme),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserMessage(Message message, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "You",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FontAwesomeIcons.user,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (message.type == MessageType.image && message.imagePath != null)

                Container(
                  constraints: const BoxConstraints(maxWidth: 280, maxHeight: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      message.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Container(
                constraints: const BoxConstraints(maxWidth: 280),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  message.content,
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBotMessage(Message message, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: message.type == MessageType.error
                ? LinearGradient(
              colors: [
                Colors.red.shade100,
                Colors.red.shade50,
              ],
            )
                : LinearGradient(
              colors: [
                Colors.grey.shade100,
                Colors.grey.shade50,
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: message.type == MessageType.error
                  ? Colors.red.shade300
                  : Colors.grey.shade300,
            ),
          ),
          child: Icon(
            message.type == MessageType.error
                ? FontAwesomeIcons.exclamationTriangle
                : FontAwesomeIcons.robot,
            size: 16,
            color: message.type == MessageType.error
                ? Colors.red.shade600
                : Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "EduBot",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (message.type == MessageType.error) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.error_outline,
                      size: 14,
                      color: Colors.red.shade400,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Consumer<ChatController>(
                builder: (context, provider, child) {
                  final isLastMessage = provider.messages.last == message;
                  final showTypingIndicator = provider.isLoading && isLastMessage;

                  return Container(
                    decoration: BoxDecoration(
                      color: message.type == MessageType.error
                          ? Colors.red.shade50
                          : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.all(
                        color: message.type == MessageType.error
                            ? Colors.red.shade200
                            : Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: showTypingIndicator
                        ? _buildTypingIndicator()
                        : Text(
                      message.content,
                      style: GoogleFonts.openSans(
                        color: message.type == MessageType.error
                            ? Colors.red.shade700
                            : Colors.grey.shade800,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Typing",
          style: GoogleFonts.openSans(
            color: Colors.grey.shade600,
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Consumer<ChatController>(
        builder: (context, provider, child) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: provider.controller.text.isNotEmpty
                    ? theme.colorScheme.primary.withOpacity(0.5)
                    : Colors.grey.shade300,
              ),
            ),
            child: TextField(
              controller: provider.controller,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
              decoration: InputDecoration(
                prefixIcon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: provider.isLoading
                        ? null
                        : LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    color: provider.isLoading ? Colors.grey.shade400 : null,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: provider.isLoading
                        ? null
                        : () => provider.sendRequestImageText(),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: provider.isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(
                        FontAwesomeIcons.camera,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                hintText: "Ask me anything...",
                hintStyle: GoogleFonts.openSans(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                suffixIcon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: provider.isLoading
                        ? null
                        : LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    color: provider.isLoading ? Colors.grey.shade400 : null,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: provider.isLoading ? null : provider.sendRequest,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: provider.isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(
                        FontAwesomeIcons.paperPlane,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showClearChatDialog(BuildContext context, ChatController provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Chat'),
          content: const Text('Are you sure you want to clear all messages?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.clearChat();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chat cleared successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _exportChat(ChatController provider) {
    final chatData = provider.exportChatAsJson();
    // Here you could implement actual export functionality
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat export functionality would be implemented here'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}