import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceInfo {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  static Future<String> getId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
  
  static Future<Map<String, String>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'osVersion': 'Android ${androidInfo.version.release}',
          'deviceId': androidInfo.id,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'model': iosInfo.model,
          'manufacturer': 'Apple',
          'osVersion': 'iOS ${iosInfo.systemVersion}',
          'deviceId': iosInfo.identifierForVendor ?? 'unknown',
        };
      }
      return {
        'model': 'Unknown',
        'manufacturer': 'Unknown',
        'osVersion': 'Unknown',
        'deviceId': 'unknown',
      };
    } catch (e) {
      return {
        'model': 'Unknown',
        'manufacturer': 'Unknown',
        'osVersion': 'Unknown',
        'deviceId': 'unknown',
      };
    }
  }
}

