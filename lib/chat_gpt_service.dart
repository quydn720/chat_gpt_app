import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants.dart';

final chatGptProvider = StateNotifierProvider<ChatGptService, List<ChatState>>(
  (ref) => ChatGptService(chats: []),
);

class ChatState {
  final Chat chat;
  final int chatState;

  ChatState(this.chat, this.chatState);
}

class ChatGptService extends StateNotifier<List<ChatState>> {
  final List<ChatState> chats;

  ChatGptService({required this.chats}) : super([]);

  Uri uri = Uri(
    scheme: 'https',
    host: 'api.openai.com',
    path: '/v1/completions',
  );

  Dio dio = Dio();

  void clear() => state = [];

  Future<void> ask(Chat question) async {
    if (question.text.isEmpty) return;

    state = [...state, ChatState(question, 1)];

    state = [...state, ChatState(Chat(text: '', isChatGpt: true), 0)];
    final result = await dio.postUri(
      uri,
      data: {
        "model": "text-davinci-003",
        "prompt": question.text,
        "temperature": 0.6,
        "max_tokens": 1000,
      },
      options: Options(
        headers: {
          Headers.contentTypeHeader: Headers.jsonContentType,
          'Authorization': 'Bearer $API_KEY',
        },
      ),
    );
    state.removeLast();
    Future.delayed(const Duration(seconds: 1), () {
      state = [
        ...state,
        ChatState(
          Chat(
            text: (result.data["choices"][0]['text'] as String).trim(),
            created: (result.data['created'] as int) * 1000,
            isChatGpt: true,
          ),
          1,
        ),
      ];
    });
  }
}

class Chat {
  final bool isChatGpt;
  final String text;
  final int? created;

  Chat({
    this.isChatGpt = false,
    this.created,
    required this.text,
  });
}
