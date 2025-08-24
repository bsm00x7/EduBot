import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controller/chat_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (BuildContext context) => ChatController(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("EduBot", style: theme.textTheme.titleMedium),
          centerTitle: true,
        ),
        body: Column(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.userCheck, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("EduBot", style: theme.textTheme.titleSmall),
                            const SizedBox(height: 4),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              // This Text exist on fois open chat [New Conversation]
                              child: Text(
                                "Hi there! I'm EduBot, your AI-powered study assistant. How can I help you today?",
                                style: GoogleFonts.openSans(),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Consumer<ChatController>(
                builder: (context, provider, child) {
                  return TextField(
                    controller: provider.controller,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: "Ask me anything...",
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      suffixIcon: provider.isloading
                          ? InkWell(


                        child: Icon(
                          FontAwesomeIcons.paperPlane,
                          size: 20,
                          color: Colors.grey.withValues(alpha: 0.4),
                        ),
                      )
                          : InkWell(
                              splashColor: Colors.transparent,
                              onTap: provider.sendRequest,
                              child: Icon(
                                FontAwesomeIcons.paperPlane,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.8,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
