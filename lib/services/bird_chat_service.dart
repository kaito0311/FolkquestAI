import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:fqa/models/bird_conversation_message.dart';

class BirdChatRequest {
  const BirdChatRequest({
    required this.question,
    required this.messages,
    required this.karma,
    required this.storyTitle,
    required this.selectedChoices,
  });

  final String question;
  final List<BirdConversationMessage> messages;
  final int karma;
  final String storyTitle;
  final List<String> selectedChoices;
}

abstract class BirdChatService {
  Future<String> reply(BirdChatRequest request);
}

class LocalBirdChatService implements BirdChatService {
  const LocalBirdChatService();

  @override
  Future<String> reply(BirdChatRequest request) async {
    return 'Khi lòng tham lớn hơn sự biết đủ, con người dễ đánh mất những gì mình đang có.';
  }
}

class BirdChatAuthRequiredException implements Exception {}

class BirdChatRemoteException implements Exception {
  const BirdChatRemoteException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FirebaseBirdChatService implements BirdChatService {
  FirebaseBirdChatService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    http.Client? httpClient,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _httpClient = httpClient ?? http.Client();

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final http.Client _httpClient;

  @override
  Future<String> reply(BirdChatRequest request) async {
    // TODO: Re-enable auth check when we require login for bird chat.
    // if (_firebaseAuth.currentUser == null) {
    //   throw BirdChatAuthRequiredException();
    // }

    final config = await _loadOpenRouterConfig();
    final response = await _httpClient.post(
      Uri.https('openrouter.ai', '/api/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://fbfirst-c8b62.web.app',
        'X-Title': 'FolkQuest',
      },
      body: jsonEncode({
        'model': config.model,
        'messages': _openRouterMessages(request),
        'temperature': 0.7,
        'max_tokens': 260,
      }),
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final message = decoded is Map<String, dynamic>
          ? decoded['error']?.toString()
          : null;
      throw BirdChatRemoteException(
        message ?? 'Không thể trò chuyện với Chim Thần lúc này.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const BirdChatRemoteException(
        'Phản hồi từ Chim Thần không hợp lệ.',
      );
    }
    final reply = _extractOpenRouterReply(decoded);
    if (reply == null || reply.isEmpty) {
      throw const BirdChatRemoteException('Chim Thần chưa kịp trả lời.');
    }
    return reply;
  }

  Future<_OpenRouterConfig> _loadOpenRouterConfig() async {
    final snapshot = await _firestore
        .collection('app_config')
        .doc('openrouter')
        .get();
    final data = snapshot.data();
    final apiKey = data?['apiKey']?.toString().trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw const BirdChatRemoteException('Chưa cấu hình OpenRouter API key.');
    }
    final model = data?['model']?.toString().trim();
    return _OpenRouterConfig(
      apiKey: apiKey,
      model: model == null || model.isEmpty
          ? 'nvidia/nemotron-3-nano-30b-a3b:free'
          : model,
    );
  }

  List<Map<String, String>> _openRouterMessages(BirdChatRequest request) {
    final history = request.messages
        .take(request.messages.length.clamp(0, 8))
        .map(
          (message) => {
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.text,
          },
        )
        .toList();
    return [
      {
        'role': 'system',
        'content':
            'Bạn là Chim Thần trong truyện Cây khế của FolkQuest. '
            'Trả lời bằng tiếng Việt, giọng hiền minh, ngắn gọn 2-4 câu, phù hợp trẻ em. '
            'Gắn bài học với lòng biết đủ, sự tử tế, trách nhiệm và lựa chọn của người chơi. '
            'Không nhắc rằng bạn là AI hay mô hình ngôn ngữ.',
      },
      {
        'role': 'user',
        'content':
            'Ngữ cảnh hiện tại: ${request.storyTitle}. '
            'Karma: ${request.karma}. '
            'Các lựa chọn đã đi qua: ${request.selectedChoices.join("; ")}.',
      },
      ...history,
      {'role': 'user', 'content': request.question},
    ];
  }

  String? _extractOpenRouterReply(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) return null;
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) return null;
    final message = firstChoice['message'];
    if (message is! Map<String, dynamic>) return null;
    return message['content']?.toString().trim();
  }
}

class _OpenRouterConfig {
  const _OpenRouterConfig({required this.apiKey, required this.model});

  final String apiKey;
  final String model;
}
