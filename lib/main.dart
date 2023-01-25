import 'package:flutter/material.dart';

void main() {
  runApp(const ChatGptApp());
}

class Chat {
  final bool isChatGpt;
  final String text;

  Chat({this.isChatGpt = false, required this.text});
}

class ChatGptApp extends StatelessWidget {
  const ChatGptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        textTheme: const TextTheme(bodyText2: TextStyle(fontSize: 20)),
      ),
      title: 'ChatGPT App with Flutter',
      home: const Home(),
    );
  }
}

class _ChatGptAppState extends State<ChatGptApp> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _conversations = <Chat>[];
  var isQuestion = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT App with Flutter',
      home: Scaffold(
        appBar: AppBar(title: const Text('ChatGPT App')),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  children: _conversations.map(
                    (e) {
                      return Text(
                        e.text,
                        textAlign:
                            e.isChatGpt ? TextAlign.start : TextAlign.end,
                      );
                    },
                  ).toList(),
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(controller: _controller)),
                  IconButton(
                    onPressed: () {
                      setState(
                        () {
                          isQuestion = !isQuestion;
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeOut,
                          );
                          _conversations.add(
                            Chat(text: _controller.text, isChatGpt: isQuestion),
                          );
                        },
                      );
                      debugPrint(_controller.text);
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
