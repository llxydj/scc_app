import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashService {
  static String generateQuizHash(
    String userId,
    String quizId,
    int score,
    DateTime timestamp,
    String deviceId,
  ) {
    final input = '$userId:$quizId:${timestamp.millisecondsSinceEpoch}:$score:$deviceId';
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static bool validateHash(
    String hash,
    String userId,
    String quizId,
    int score,
    DateTime timestamp,
    String deviceId,
  ) {
    final expectedHash = generateQuizHash(userId, quizId, score, timestamp, deviceId);
    return hash == expectedHash;
  }
}

