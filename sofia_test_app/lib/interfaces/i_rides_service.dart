

import 'package:sofia_test_app/models/Ride.dart';
import 'package:sofia_test_app/models/RideSearchParameters.dart';

abstract class IRidesService {
  Future<Ride> addAsync(Ride ride);
  Future<List<Ride>> searchAsync(RideSearchParameters parameters);
}
