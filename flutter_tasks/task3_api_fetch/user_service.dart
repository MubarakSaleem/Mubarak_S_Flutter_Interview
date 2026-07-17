import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';

/// Custom exception so the UI layer can show a friendly message instead of
/// a raw exception type/string.
class UserFetchException implements Exception {
  final String message;
  UserFetchException(this.message);

  @override
  String toString() => message;
}

/// Networking layer — completely separate from any widget. This is the
/// only file that knows about `http` or the JSONPlaceholder URL.
class UserService {
  static const _usersUrl = 'https://jsonplaceholder.typicode.com/users';

  final http.Client _client;

  /// Accepting an injectable client (defaulting to a real one) makes this
  /// service unit-testable with a mocked client if needed later.
  UserService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<UserModel>> fetchUsers() async {
    try {
      final response = await _client
          .get(Uri.parse(_usersUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw UserFetchException(
          'Server returned ${response.statusCode}. Please try again.',
        );
      }

      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on UserFetchException {
      rethrow;
    } catch (e) {
      // Covers timeouts, no-connectivity (SocketException), malformed JSON, etc.
      throw UserFetchException(
        'Could not load users. Check your connection and try again.',
      );
    }
  }
}
