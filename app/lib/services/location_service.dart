import 'package:employee_flutter/utils/utilis.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationService {
  Location location = Location();
  late LocationData _locData;

  Future<Map<String, double?>?> initializeAndGetLocation(
      BuildContext context) async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // First check whether location is enabled or not in the device
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        Utils.showSnackBar("Please Enable Location Service", context);
        return null;
      }
    }
    // If service is enabled then ask permission for location from user
    permissionGranted = await location.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        Utils.showSnackBar("Please Allow Location Access", context);
        return null;
      }
    }

    // After permissison is granted then return the cordinates
    _locData = await location.getLocation();
    return {
      'latitude': _locData.latitude,
      'longitude': _locData.longitude,
    };
  }
}
