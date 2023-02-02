import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_gpt_app/chat_gpt_service.dart';
import 'package:chat_gpt_app/color_schemes.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: ChatGptApp()));
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

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends ConsumerState<Home> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  var isQuestion = true;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final c = (ref.watch(chatGptProvider));

    ref.listen(chatGptProvider, (previous, next) {
      if (next != previous) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT App'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(chatGptProvider.notifier).clear();
            },
            icon: const Icon(Icons.delete),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  children: c.map(
                    (e) {
                      return Align(
                        alignment: e.isChatGpt
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          margin: EdgeInsets.only(
                            left: e.isChatGpt ? 0 : 70,
                            right: e.isChatGpt ? 70 : 0,
                            bottom: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: e.isChatGpt
                                ? colorScheme.outline
                                : colorScheme.primary,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(e.text, softWrap: true),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      minLines: 1,
                      maxLines: 5,
                      controller: _controller,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            ref.read(chatGptProvider.notifier).ask(
                                  Chat(
                                    text: _controller.text,
                                    created:
                                        DateTime.now().millisecondsSinceEpoch,
                                  ),
                                );

                            _controller.clear();
                          },
                          icon: const Icon(Icons.send),
                        ),
                      ),
                    ),
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

            child: chat.chatState == 0
                ? AnimatedTextKit(
                    animatedTexts: [TypewriterAnimatedText('...')])
                // const Dots()
                :
                // AnimatedTextKit(
                //     totalRepeatCount: 1,
                //     animatedTexts: [TypewriterAnimatedText(chat.chat.text)],
                //   ),
                Text(chat.chat.text, softWrap: true),
