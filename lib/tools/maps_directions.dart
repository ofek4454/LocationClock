import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locationAlarm/key.dart';

class MapsDirections {
  static String get key {
    return GOOGLE_API_KEY;
  }

  static Future<String> getLocationaddress(LatLng userLocation) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${userLocation.latitude},${userLocation.longitude}&key=$key';
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      final responseData = json.decode(response.body);
      final formattedAddress = responseData['results'][0]['formatted_address'];
      return formattedAddress;
    } catch (error) {
      throw error;
    }
  }

  static Future<dynamic> getDirections(
      LatLng userLocation, String whereToGo) async {
    final useraddress = await getLocationaddress(userLocation);
    print(useraddress);
    final url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=$useraddress&destination=$whereToGo'
        '&key=$key';
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      throw error;
    }
  }

  static Future<dynamic> getDirectionsUpdate(
      LatLng userLocation, LatLng whereToGo) async {
    final url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${userLocation.latitude},${userLocation.longitude}&destination=${whereToGo.latitude},${whereToGo.longitude}'
        '&key=$key';

    print(url);
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      throw error;
    }
  }
}
