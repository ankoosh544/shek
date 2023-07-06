class RideSearchParameters {
  String? elevatorId;
  DateTime? from;
  DateTime? to;
  String? username;
  String? startingFloor;
  String? targetFloor;
  int? length;

  RideSearchParameters({
    this.elevatorId,
    this.from,
    this.to,
    this.username,
    this.startingFloor,
    this.targetFloor,
    this.length,
  });
}
