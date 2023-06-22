import 'package:flutter/services.dart';
import 'package:sofia_test_app/interfaces/i_audio_service.dart';

class AudioService implements IAudioService {
  static const MethodChannel _channel = const MethodChannel('audio_service');

  @override
  bool beep() {
    try {
      _channel.invokeMethod('beep');
      return true;
    } catch (e) {
      return false;
    }
  }
}
