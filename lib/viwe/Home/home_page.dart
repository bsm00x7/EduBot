import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
                          Text(
                            "EduBot",
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            // This Text exist on fois open chat [New Conversation]
                            child:  Text(
                              "Hi there! I'm EduBot, your AI-powered study assistant. How can I help you today?",style:GoogleFonts.openSans(),
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
          TextField(
            decoration: InputDecoration(
              hint: Text("Ask me anything..."),
              hintStyle: theme.textTheme.titleSmall!.copyWith(color: Colors.grey.withValues(alpha: 0.4))
            ),
          )
        ],
      ),
    );
  }
}
