import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
    FirebaseFirestore? firestore,
    http.Client? httpClient,
    Duration providerConfigCacheTtl = const Duration(minutes: 5),
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _httpClient = httpClient ?? http.Client(),
       _providerConfigCacheTtl = providerConfigCacheTtl;

  final FirebaseFirestore _firestore;
  final http.Client _httpClient;
  final Duration _providerConfigCacheTtl;

  _OpenRouterConfig? _cachedProviderConfig;
  DateTime? _providerConfigCachedAt;
  Future<_OpenRouterConfig>? _providerConfigLoad;

  @override
  Future<String> reply(BirdChatRequest request) async {
    // NOTE: Re-enable auth check when we require login for bird chat.
    // if (_firebaseAuth.currentUser == null) {
    //   throw BirdChatAuthRequiredException();
    // }

    final response = await _postChatRequestWithConfigRefresh(request);

    final decoded = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final message = decoded is Map<String, dynamic>
          ? decoded['error']?.toString()
          : null;
      throw BirdChatRemoteException(
        message ??
            'Không thể trò chuyện với Chim Thần lúc này. Vui lòng thử lại sau.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const BirdChatRemoteException(
        'Phản hồi từ Chim Thần không hợp lệ. Vui lòng thử lại sau.',
      );
    }
    final reply = _extractOpenAIReply(decoded);
    if (reply == null || reply.isEmpty) {
      throw const BirdChatRemoteException('Chim Thần chưa kịp trả lời.');
    }
    return reply;
  }

  Future<http.Response> _postChatRequestWithConfigRefresh(
    BirdChatRequest request,
  ) async {
    var config = await _loadProviderConfig();

    try {
      final response = await _postChatRequest(config, request);
      if (response.statusCode == 200) {
        return response;
      }
    } catch (_) {
      // The provider config may have changed; retry once with a fresh snapshot.
    }

    config = await _loadProviderConfig(forceRefresh: true);
    return _postChatRequest(config, request);
  }

  Future<http.Response> _postChatRequest(
    _OpenRouterConfig config,
    BirdChatRequest request,
  ) {
    return _httpClient.post(
      Uri.parse(config.hostUrl),
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': config.model,
        'messages': _openAIChatMessages(request),
      }),
    );
  }

  Future<_OpenRouterConfig> _loadProviderConfig({
    bool forceRefresh = false,
  }) async {
    final cachedAt = _providerConfigCachedAt;
    final cachedConfig = _cachedProviderConfig;
    final cacheIsFresh =
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _providerConfigCacheTtl;

    if (!forceRefresh && cachedConfig != null && cacheIsFresh) {
      return cachedConfig;
    }

    if (!forceRefresh) {
      final existingLoad = _providerConfigLoad;
      if (existingLoad != null) {
        return existingLoad;
      }
    }

    final load = _fetchProviderConfig();
    _providerConfigLoad = load;
    try {
      final config = await load;
      _cachedProviderConfig = config;
      _providerConfigCachedAt = DateTime.now();
      return config;
    } finally {
      if (identical(_providerConfigLoad, load)) {
        _providerConfigLoad = null;
      }
    }
  }

  Future<_OpenRouterConfig> _fetchProviderConfig() async {
    final snapshot = await _firestore
        .collection('app_config')
        .doc('openrouter')
        .get();
    final data = snapshot.data();
    final apiKey = data?['apiKey']?.toString().trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw const BirdChatRemoteException('Chưa cấu hình API key.');
    }

    final hostUrl = data?['hostUrl']?.toString().trim();

    if (hostUrl == null || hostUrl.isEmpty) {
      throw const BirdChatRemoteException(
        'Chưa cấu hình OpenRouter hostUrl. '
        'Vui lòng xóa trường hostUrl trong Firestore app_config/openrouter.',
      );
    }
    final model = data?['model']?.toString().trim();
    return _OpenRouterConfig(
      apiKey: apiKey,
      model: model == null || model.isEmpty
          ? 'nvidia/nemotron-3-nano-30b-a3b:free'
          : model,
      hostUrl: hostUrl,
    );
  }

  List<Map<String, String>> _openAIChatMessages(BirdChatRequest request) {
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
        'role': 'system',
        'content':
            'Ngữ cảnh hiện tại: ${request.storyTitle}. '
            'Karma: ${request.karma}. '
            'Các lựa chọn đã đi qua: ${request.selectedChoices.join("; ")}.',
      },
      ...history,
      {'role': 'user', 'content': request.question},
    ];
  }

  String? _extractOpenAIReply(dynamic decoded) {
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
  const _OpenRouterConfig({
    required this.apiKey,
    required this.model,
    required this.hostUrl,
  });

  final String apiKey;
  final String model;
  final String hostUrl;
}
