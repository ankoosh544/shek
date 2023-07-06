class Ride {
  int? id;
  String? elevatorId;
  DateTime? start;
  String? startingFloor;
  String? targetFloor;
  String? username;

  Ride({
    this.id,
    this.elevatorId,
    this.start,
    this.startingFloor,
    this.targetFloor,
    this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'elevatorId': elevatorId,
      'start': start!.millisecondsSinceEpoch,
      'startingFloor': startingFloor,
      'targetFloor': targetFloor,
      'username': username,
    };
  }

  static Ride fromMap(Map<String, dynamic> map) {
    return Ride(
      id: map['id'],
      elevatorId: map['elevatorId'],
      start: DateTime.fromMillisecondsSinceEpoch(map['start']),
      startingFloor: map['startingFloor'],
      targetFloor: map['targetFloor'],
      username: map['username'],
    );
  }
}
