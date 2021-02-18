import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:locationAlarm/tools/maps_directions.dart';

import '../widgets/input_bar.dart';
import '../widgets/loading_widget.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LocationData _userLocation;
  Location _location;
  GoogleMapController _mapController;
  bool isInit = false;
  bool isLoading = false;
  String distance, time;
  Timer timer;

  // this set will hold my markers
  Set<Marker> _markers = {};
  // this will hold the generated polylines
  Set<Polyline> _polylines = {};
// this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
// this is the key object - the PolylinePoints
// which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();

  void initState() {
    super.initState();
    getLocation();
  }

  LatLng get userLanLng {
    return LatLng(_userLocation.latitude, _userLocation.longitude);
  }

  Future<void> search(String val) async {
    setState(() {
      isLoading = true;
    });
    final result = await MapsDirections.getDirections(userLanLng, val);
    distance = result['routes'][0]['legs'][0]['distance']['text'];
    time = result['routes'][0]['legs'][0]['duration']['text'];

    final source = result['routes'][0]['legs'][0]['start_location'];
    final sourceLatLng = LatLng(source['lat'], source['lng']);

    final dest = result['routes'][0]['legs'][0]['end_location'];
    final destLatLng = LatLng(dest['lat'], dest['lng']);

    setMapPins(sourceLatLng, destLatLng);
    setPolylines(sourceLatLng, destLatLng);
    setState(() {
      isLoading = false;
    });

    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      update(val);
    });
  }

  Future<void> update(String val) async {
    final result = await MapsDirections.getDirections(userLanLng, val);
    setState(() {
      distance = result['routes'][0]['legs'][0]['distance']['text'];
      time = result['routes'][0]['legs'][0]['duration']['text'];
    });
  }

  void setMapPins(LatLng sourceLatLng, LatLng destLatLng) {
    setState(() {
      // source pin
      // _markers.add(Marker(
      //   markerId: MarkerId('sourcePin'),
      //   position: sourceLatLng,
      // ));
      // destination pin
      _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destLatLng,
      ));
    });
  }

  setPolylines(LatLng sourceLatLng, LatLng destLatLng) async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        MapsDirections.key,
        sourceLatLng.latitude,
        sourceLatLng.longitude,
        destLatLng.latitude,
        destLatLng.longitude);
    if (result.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
          polylineId: PolylineId('poly'),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates);

      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines.add(polyline);
    });
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

  Future<void> getLocation() async {
    //_userLocation = await Location.instance.getLocation();
    await getPermission();
    try {
      _location.onLocationChanged.listen((LocationData currentLocation) {
        // Use current location
        setState(() {
          _userLocation = currentLocation;
        });
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                _userLocation.latitude,
                _userLocation.longitude,
              ),
              zoom: 16,
            ),
          ),
        );
      });
    } catch (error) {
      print(error);
    }
    if (isInit == false && _mapController != null) {
      setState(() {
        isInit = true;
      });
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _userLocation.latitude,
              _userLocation.longitude,
            ),
            zoom: 16,
          ),
        ),
      );
    }
  }

  void stop() {
    setState(() {
      if (timer.isActive) {
        timer.cancel();
      }
      timer = null;
      distance = null;
      time = null;

      _markers = {};
      _polylines = {};
      polylineCoordinates = [];
      polylinePoints = PolylinePoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool navigate = distance != null && time != null;
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm'),
      ),
      body: Container(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: navigate
                    ? MediaQuery.of(context).size.height * 0.85
                    : double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(100, 100),
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  zoomControlsEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (isInit == false && _userLocation != null) {
                      setState(() {
                        isInit = true;
                      });
                      _mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              _userLocation.latitude,
                              _userLocation.longitude,
                            ),
                            zoom: 16,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!navigate)
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: InputBar(search),
                  ),
                if (navigate)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                    ),
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 8,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('distance: $distance'),
                              Text('duration: $time'),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                            ),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.1,
                              child: RaisedButton(
                                color: Colors.red,
                                onPressed: stop,
                                child: Text('הפסק'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (_userLocation != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 80,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('lat: ${_userLocation.latitude}'),
                      SizedBox(
                        width: 20,
                      ),
                      Text('lng: ${_userLocation.longitude}'),
                    ],
                  ),
                ),
              ),
            if (!isInit || isLoading) LoadingWidget()
          ],
        ),
      ),
    );
  }
}
