class NotificationEventArgs {
  String? title;
  String? message;

  String? get Title => title;
  set Title(String? value) => title = value;

  String? get Message => message;
  set Message(String? value) => message = value;

  NotificationEventArgs({this.title, this.message});
}
