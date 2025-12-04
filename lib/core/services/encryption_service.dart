import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _keyStorageKey = 'encryption_key';
  static const String _ivStorageKey = 'encryption_iv';

  Key? _key;
  IV? _iv;
  Encrypter? _encrypter;

  Future<void> _initialize() async {
    if (_encrypter != null) return;

    try {
      // Try to load existing key and IV
      final keyString = await _secureStorage.read(key: _keyStorageKey);
      final ivString = await _secureStorage.read(key: _ivStorageKey);

      if (keyString != null && ivString != null) {
        _key = Key.fromBase64(keyString);
        _iv = IV.fromBase64(ivString);
      } else {
        // Generate new key and IV
        _key = Key.fromSecureRandom(32); // AES-256
        _iv = IV.fromSecureRandom(16);
        
        // Store them securely
        await _secureStorage.write(key: _keyStorageKey, value: _key!.base64);
        await _secureStorage.write(key: _ivStorageKey, value: _iv!.base64);
      }

      _encrypter = Encrypter(AES(_key!));
    } catch (e) {
      // If encryption fails, continue without it
      print('Encryption initialization failed: $e');
    }
  }

  Future<String> encrypt(String plainText) async {
    try {
      await _initialize();
      if (_encrypter == null || _iv == null) {
        // If encryption not available, return base64 encoded
        return base64Encode(utf8.encode(plainText));
      }
      final encrypted = _encrypter!.encrypt(plainText, iv: _iv!);
      return encrypted.base64;
    } catch (e) {
      // Fallback to base64 encoding
      return base64Encode(utf8.encode(plainText));
    }
  }

  Future<String> decrypt(String encrypted) async {
    try {
      await _initialize();
      if (_encrypter == null || _iv == null) {
        // If encryption not available, try base64 decode
        return utf8.decode(base64Decode(encrypted));
      }
      final encryptedData = Encrypted.fromBase64(encrypted);
      return _encrypter!.decrypt(encryptedData, iv: _iv!);
    } catch (e) {
      // Fallback to base64 decoding
      try {
        return utf8.decode(base64Decode(encrypted));
      } catch (_) {
        return encrypted; // Return as-is if decryption fails
      }
    }
  }
}

