import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:locationAlarm/tools/maps_directions.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WakeUpBy {
  Time,
  Distance,
}

class AppController with ChangeNotifier {
  LocationData _userLocation;
  Location _location;
  String _distance, _time;
  Timer _timer;
  dynamic _source, _dest;
  LatLng _sourceLatLng, _destLatLng;
  WakeUpBy _wakeUpBy;
  int _timeToWake;
  double _distanceToWake;
  Function ring;
  bool wasRing = false;

  // this set will hold my markers
  Set<Marker> _markers = {};
  // this will hold the generated polylines
  Set<Polyline> _polylines = {};
// this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> _polylineCoordinates = [];
// this is the key object - the PolylinePoints
// which generates every polyline between start and finish
  PolylinePoints _polylinePoints = PolylinePoints();

  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  List<LatLng> get polylineCoordinates => _polylineCoordinates;
  PolylinePoints get polylinePoints => _polylinePoints;
  LocationData get userLocation => _userLocation;
  String get time => _time;
  String get distance => _distance;
  Location get location => _location;
  WakeUpBy get wakeUpBy => _wakeUpBy;
  int get timeToWake => _timeToWake;
  double get distanceToWake => _distanceToWake;

  void set userLocation(LocationData locationData) =>
      _userLocation = locationData;

  void set wakeUpBy(WakeUpBy wakeBy) => _wakeUpBy = wakeBy;

  LatLng get userLanLng {
    return LatLng(_userLocation.latitude, _userLocation.longitude);
  }

  bool get navigate => _distance != null && _time != null;

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('wakeUpBy') &&
        prefs.getString('wakeUpBy').isNotEmpty) {
      _wakeUpBy = prefs.getString('wakeUpBy') == 'Time'
          ? WakeUpBy.Time
          : WakeUpBy.Distance;
    } else {
      prefs.setString('wakeUpBy', 'Time');
      _wakeUpBy = WakeUpBy.Time;
    }

    if (prefs.containsKey('TimeToWake') &&
        prefs.getString('TimeToWake').isNotEmpty) {
      _timeToWake = int.parse(prefs.getString('TimeToWake'));
    } else {
      prefs.setString('TimeToWake', '5');
      _timeToWake = 5;
    }

    if (prefs.containsKey('DistanceToWake') &&
        prefs.getString('DistanceToWake').isNotEmpty) {
      _distanceToWake = double.parse(prefs.getString('DistanceToWake'));
    } else {
      prefs.setString('DistanceToWake', '5');
      _distanceToWake = 5;
    }
  }

  Future<void> saveSettings(String val) async {
    final prefs = await SharedPreferences.getInstance();
    if (_wakeUpBy == WakeUpBy.Time) {
      prefs.setString('wakeUpBy', 'Time');
      prefs.setString('TimeToWake', val);
      _timeToWake = int.parse(val);
    } else {
      prefs.setString('wakeUpBy', 'Distance');
      prefs.setString('DistanceToWake', val);
      _distanceToWake = double.parse(val);
    }
  }

  Future<void> search(String val) async {
    final result = await MapsDirections.getDirections(userLanLng, val);
    _distance = result['routes'][0]['legs'][0]['distance']['text'];
    _time = result['routes'][0]['legs'][0]['duration']['text'];

    _source = result['routes'][0]['legs'][0]['start_location'];
    _sourceLatLng = LatLng(_source['lat'], _source['lng']);

    _dest = result['routes'][0]['legs'][0]['end_location'];
    _destLatLng = LatLng(_dest['lat'], _dest['lng']);

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _update(val);
    });

    _setMapPins();
    await setPolylines();
  }

  void _setMapPins() {
    // source pin
    // _markers.add(Marker(
    //   markerId: MarkerId('sourcePin'),
    //   position: sourceLatLng,
    // ));
    // destination pin
    _markers.add(Marker(
      markerId: MarkerId('destPin'),
      position: _destLatLng,
    ));
  }

  Future<void> setPolylines() async {
    List<PointLatLng> result =
        await _polylinePoints?.getRouteBetweenCoordinates(
            MapsDirections.key,
            _sourceLatLng.latitude,
            _sourceLatLng.longitude,
            _destLatLng.latitude,
            _destLatLng.longitude);
    if (result.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      result.forEach((PointLatLng point) {
        _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    // create a Polyline instance
    // with an id, an RGB color and the list of LatLng pairs
    Polyline polyline = Polyline(
        polylineId: PolylineId('poly'),
        color: Color.fromARGB(255, 40, 122, 198),
        points: _polylineCoordinates);

    // add the constructed polyline as a set of points
    // to the polyline set, which will eventually
    // end up showing up on the map
    _polylines.add(polyline);
  }

  Future<void> _update(String val) async {
    final result =
        await MapsDirections.getDirectionsUpdate(userLanLng, _destLatLng);
    _distance = result['routes'][0]['legs'][0]['distance']['text'];
    _time = result['routes'][0]['legs'][0]['duration']['text'];
    int formatTime;
    if (_time.contains('mins')) {
      formatTime = int.tryParse(_time.replaceAll('mins', ''));
    } else if (time.contains('min')) {
      formatTime = int.tryParse(_time.replaceAll('min', ''));
    }

    final formatDistance = double.tryParse(_distance.replaceAll('km', ''));
    notifyListeners();
    if (formatTime == 0 || formatDistance <= 0.1) {
      //arrive
      ring('הגענו!');
      stop();
    }

    if (_wakeUpBy == WakeUpBy.Time) {
      if (formatTime <= _timeToWake && !wasRing) {
        wasRing = true;
        ring('אנחנו עומדים להגיע!');
      }
    } else {
      if (formatDistance <= _distanceToWake && !wasRing) {
        wasRing = true;
        ring('אנחנו עומדים להגיע!');
      }
    }
  }

  void stop() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _timer = null;
    _distance = null;
    _time = null;

    _markers = {};
    _polylines = {};
    _polylineCoordinates = [];
    _polylinePoints = PolylinePoints();
    wasRing = false;
  }

  Future<void> getPermission() async {
    _location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _userLocation = await _location.getLocation();
  }
}
