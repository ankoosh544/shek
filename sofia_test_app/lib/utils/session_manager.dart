import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String appLanguageKey = "AppLanguage";
  static const String visualMessagesKey = "VisualMessages";
  static const String audioMessagesKey = "AudioMessages";
  static const String touchCommandKey = "TouchCommand";
  static const String audioCommandKey = "AudioCommand";
  static const String priorityPresidentKey = "PriorityPresident";
  static const String priorityDisablePeopleKey = "PriorityDisablePeople";
  static const String passwordUtenteKey = "PasswordUtente";
  static const String isDisablePeopleKey = "IsDisablePeople";
  static const String isPresidentKey = "IsPresident";

  static SharedPreferences? _preferences;

  static Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static String getString(String key, {String defaultValue = ""}) {
    return _preferences?.getString(key) ?? defaultValue;
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _preferences?.getBool(key) ?? defaultValue;
  }

  static Future<bool> setString(String key, String value) {
    return _preferences?.setString(key, value) ?? Future.value(false);
  }

  static Future<bool> setBool(String key, bool value) {
    return _preferences?.setBool(key, value) ?? Future.value(false);
  }
}
