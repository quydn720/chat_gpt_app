import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants.dart';

final chatGptProvider = StateNotifierProvider<ChatGptService, List<Chat>>(
  (ref) => ChatGptService(chats: []),
);

class ChatGptService extends StateNotifier<List<Chat>> {
  final List<Chat> chats;
  final int chatState; // 0: loading, 1: loaded,...

  ChatGptService({this.chatState = 0, required this.chats}) : super([]);

  Uri uri = Uri(
    scheme: 'https',
    host: 'api.openai.com',
    path: '/v1/completions',
  );

  Dio dio = Dio();

  void clear() => state = [];

  Future<void> ask(Chat question) async {
    state = [...state, question];

    final result = await dio.postUri(
      uri,
      data: {
        "model": "text-davinci-003",
        "prompt": question.text,
        "temperature": 0.6,
        "max_tokens": 100,
      },
      options: Options(
        headers: {
          Headers.contentTypeHeader: Headers.jsonContentType,
          'Authorization': 'Bearer $API_KEY',
        },
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      state = [
        ...state,
        Chat(
          text: (result.data["choices"][0]['text'] as String).trim(),
          isChatGpt: true,
        )
      ];
    });
  }
}

class Chat {
  final bool isChatGpt;
  final String text;

  Chat({this.isChatGpt = false, required this.text});
}
