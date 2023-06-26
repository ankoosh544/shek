import 'package:sofia/models/Ride.dart';
import 'package:sofia/models/RideSearchParameters.dart';

abstract class IRidesService {
  Future<Ride> addAsync(Ride ride);
  Future<List<Ride>> searchAsync(RideSearchParameters parameters);
}
