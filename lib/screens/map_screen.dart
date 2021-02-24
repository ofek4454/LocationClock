import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../controller.dart';
import '../widgets/input_bar.dart';
import '../widgets/loading_widget.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController _mapController;
  bool isInit = false;
  bool isLoading = false;

  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInit) {
      if (Provider.of<AppController>(context, listen: false).userLocation ==
          null) {
        getLocation();
      }
    }
  }

  Future<void> search(String val) async {
    setState(() {
      isLoading = true;
    });
    await Provider.of<AppController>(context, listen: false).search(val);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getLocation() async {
    final controller = Provider.of<AppController>(context, listen: false);

    //_userLocation = await Location.instance.getLocation();
    await controller.getPermission();
    try {
      controller.location.onLocationChanged
          .listen((LocationData currentLocation) {
        // Use current location
        setState(() {
          controller.userLocation = currentLocation;
        });
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                controller.userLocation.latitude,
                controller.userLocation.longitude,
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
              controller.userLocation.latitude,
              controller.userLocation.longitude,
            ),
            zoom: 16,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AppController>(context);
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
                height: controller.navigate
                    ? MediaQuery.of(context).size.height * 0.85
                    : double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(100, 100),
                  ),
                  markers: controller.markers,
                  polylines: controller.polylines,
                  zoomControlsEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (mapController) {
                    _mapController = mapController;
                    if (isInit == false && controller.userLocation != null) {
                      setState(() {
                        isInit = true;
                      });
                      _mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              controller.userLocation.latitude,
                              controller.userLocation.longitude,
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
                if (!controller.navigate)
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: InputBar(search),
                  ),
                if (controller.navigate)
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
                              Text('distance: ${controller.distance}'),
                              Text('duration: ${controller.time}'),
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
                                onPressed: () => setState(() {
                                  controller.stop();
                                }),
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
            if (controller.userLocation != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 80,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('lat: ${controller.userLocation.latitude}'),
                      SizedBox(
                        width: 20,
                      ),
                      Text('lng: ${controller.userLocation.longitude}'),
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
