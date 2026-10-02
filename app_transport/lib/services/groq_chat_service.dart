import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GroqChatException implements Exception {
  final String message;
  const GroqChatException(this.message);

  @override
  String toString() => message;
}

class GroqChatService {
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'openai/gpt-oss-20b';
  static const _systemPrompt = '''
IDENTITY
You are "App Assistant", the official travel assistant inside App Transport.
You help travelers during an Egypt layover or trip.

SCOPE
You may discuss only: App Transport trips, Flying Taxi, Transit Trips, Egyptian destinations and landmarks, airport transportation, trip duration and price, booking guidance, cancellation guidance, and general travel tips for Egypt.
You may explain how to use these app sections: Home, Flying Taxi, Transit Trips, My Bookings, AI Chat, Profile, and Admin tools.

DATA AND TRUTH POLICY
1. The AVAILABLE TRIPS section in the user message is the source of truth for current trips, prices, duration, routes, descriptions, and availability.
2. The CURRENT USER BOOKINGS section contains only the signed-in user's booking data and is the source of truth for booking status and details. Never expose internal booking IDs; refer to bookings by trip name, date, and status only.
3. Never invent a trip, price, schedule, route, booking, payment status, cancellation, or user profile detail.
4. If a requested trip is not in AVAILABLE TRIPS, say that its current details are not available in the app and suggest opening the Trips section. Do not say it is permanently unavailable.
5. If booking data is not provided, say you cannot see the user's bookings and direct them to My Bookings. Never claim a booking exists or was changed.
6. If trip data is marked unavailable or refreshing, say that the app is refreshing trip data and ask the user to try again.
7. Do not claim to have performed an action. The assistant can explain steps, but booking, payment, cancellation, and profile changes must be completed through the app UI.

RESPONSE STYLE
Be concise, helpful, and friendly. Reply in the same language as the latest user message (Arabic or English). Use clear bullets when listing trips, bookings, or steps. Never use Markdown tables; tables become unreadable on mobile. Ask one useful follow-up question when details are missing.

OFF-TOPIC POLICY
For politics, sports, coding, technology, unrelated news, or any non-travel request, reply exactly: "I specialize only in tourism and travel within Egypt. I cannot answer that. Do you have a tourism-related question?"
''';

  final http.Client _client;
  final List<Map<String, String>> _history = [];

  GroqChatService({http.Client? client}) : _client = client ?? http.Client();

  List<Map<String, String>> get history => List.unmodifiable(_history);

  Future<String> sendMessage(String message, {String tripContext = ''}) async {
    final text = message.trim();
    if (text.isEmpty) {
      throw const GroqChatException('Please enter a message.');
    }

    final apiKey = dotenv.env['GROQ_API_KEY']?.trim() ?? '';
    if (apiKey.isEmpty || apiKey == 'replace_with_your_groq_key') {
      throw const GroqChatException(
        'Groq API key is missing. Add GROQ_API_KEY to .env and restart the app.',
      );
    }

    final userMessage = {'role': 'user', 'content': text};
    _history.add(userMessage);

    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content': '$_systemPrompt\nAvailable trips:\n$tripContext',
                },
                ..._history,
              ],
              'temperature': 0.2,
              'max_tokens': 700,
            }),
          )
          .timeout(const Duration(seconds: 35));

      final data = _decodeResponse(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _history.removeLast();
        final apiMessage = data['error'] is Map
            ? (data['error'] as Map)['message']?.toString()
            : null;
        throw GroqChatException(
          _messageForStatus(response.statusCode, apiMessage),
        );
      }

      final reply =
          ((data['choices'] as List?)?.firstOrNull as Map?)?['message'];
      final rawContent = reply is Map
          ? reply['content']?.toString().trim()
          : null;
      final content = rawContent == null ? null : _formatForMobile(rawContent);
      if (content == null || content.isEmpty) {
        _history.removeLast();
        throw const GroqChatException(
          'The assistant returned an empty response.',
        );
      }

      _history.add({'role': 'assistant', 'content': content});
      return content;
    } on GroqChatException {
      rethrow;
    } on FormatException {
      _history.removeLast();
      throw const GroqChatException(
        'The AI service returned an invalid response.',
      );
    } catch (_) {
      _history.removeLast();
      throw const GroqChatException(
        'Connection failed. Check your internet connection and try again.',
      );
    }
  }

  Map<String, dynamic> _decodeResponse(String body) {
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  String _messageForStatus(int status, String? apiMessage) {
    if (status == 401) return 'The Groq API key is invalid or expired.';
    if (status == 429) {
      return 'Groq rate limit reached. Please try again shortly.';
    }
    if (status >= 500) {
      return 'Groq is temporarily unavailable. Please try again.';
    }
    return apiMessage == null || apiMessage.isEmpty
        ? 'The assistant request failed ($status).'
        : apiMessage;
  }

  String _formatForMobile(String content) {
    final lines = content.split('\n');
    final hasTable = lines.any(
      (line) => line.trim().startsWith('|') && line.trim().endsWith('|'),
    );
    if (!hasTable) return content;

    final formatted = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('|') || !trimmed.endsWith('|')) {
        formatted.add(line);
        continue;
      }
      final cells = trimmed
          .substring(1, trimmed.length - 1)
          .split('|')
          .map((cell) => cell.trim())
          .toList();
      if (cells.isEmpty ||
          cells.every((cell) => RegExp(r'^:?-+:?$').hasMatch(cell))) {
        continue;
      }
      formatted.add('- ${cells.join('  •  ')}');
    }
    return formatted.join('\n');
  }

  void clearHistory() => _history.clear();

  void dispose() => _client.close();
}
