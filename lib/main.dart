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

class ChatBubble extends StatelessWidget {
  const ChatBubble({Key? key, required this.chat}) : super(key: key);

  final ChatState chat;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String? date(int? created) {
      if (created != null) {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(
          chat.chat.created!,
          isUtc: false,
        );
        final now = DateTime.now();
        if (dateTime.difference(now).inDays <= 0) {
          return '${dateTime.hour}:${dateTime.minute}';
        }
        if (dateTime.difference(now).inDays <= 0) {
          return '${dateTime.hour}:${dateTime.minute}';
        }
        return dateTime.toString();
      }
      return null;
    }

    return Column(
      children: [
        Text(date(chat.chat.created) ?? ''),
        Card(
          margin: EdgeInsets.only(
            left: chat.chat.isChatGpt ? 0 : 70,
            right: chat.chat.isChatGpt ? 70 : 0,
            bottom: 12,
          ),
          color: chat.chat.isChatGpt ? Colors.white : colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(12),
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
          ),
        ),
      ],
    );
  }
}

class Dots extends StatefulWidget {
  const Dots({Key? key}) : super(key: key);

  @override
  State<Dots> createState() => _DotsState();
}

class _DotsState extends State<Dots> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> animations;

  final tween = Tween<double>(begin: 0.0, end: -8);
  final List<Interval> dotIntervals = [
    const Interval(0.25, 0.8),
    const Interval(0.35, 0.9),
    const Interval(0.45, 1.0),
  ];
  late final Animation<double> opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }

        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });

    opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    animations = List.generate(
      3,
      (index) => CurvedAnimation(
        parent: _controller,
        curve: dotIntervals[index],
        reverseCurve: dotIntervals[(2 - index).abs()],
      ).drive(tween),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (index) => AnimatedBuilder(
          animation: animations[index],
          builder: (context, child) => Transform.translate(
            offset: Offset(0, animations[index].value),
            child: Opacity(
              opacity: opacity.value,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                margin: const EdgeInsets.only(right: 5),
                height: 10,
                width: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
