import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

class Locationtoserver {
  String? roomcode;
  String? url;
  String? lon;
  String? lat;
  String? id;

  Locationtoserver({this.url});

  Future<String> getData(lon, lat, roomcode, id) async {
    var response = await http.post(Uri.parse(url ?? ''), body: {
      'id': '$id',
      'lat': '$lat',
      'lon': '$lon',
      'roomcode': '$roomcode'
    });
    print('Response status: ${response.statusCode}');
    return response.body;
  }
}

class Locationstatus {
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  bool _serviceEnabled = false;
  String? lat;
  String? long;

  Future<bool> checkLocationPermission(Location location) async {
    // Check if location service is enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    // Check if location permission is granted
    if (_permissionGranted != PermissionStatus.granted) {
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return false;
        }
      }
    }
    return true;
  }
}

class Senser {
  List<List<double>> matri = [];
  List<List<double>> matr = [];
  int maxDataPoints = 50;
  int currentDataPoints = 0;
  int currentData = 0;

  Future<String> getgyro() async {
     gyroscopeEvents.listen(
      (GyroscopeEvent event) {
        if (currentDataPoints != maxDataPoints) {
          matri.add([event.x, event.y, event.z]);
          currentDataPoints++;
        }
      },
    );
    return ("ok");
  }

  Future<String> getacc(soc, da, host) async {
    accelerometerEvents.listen(
      (AccelerometerEvent event) {
        matr.add([event.x, event.y, event.z]);
        if (currentData == maxDataPoints) {
          if (currentDataPoints == maxDataPoints) {
            soc.emit('Sencordata', {
              'id': da,
              "acc": matr,
              "gyo": matri,
              "host": host,
              "out": 0,
            });
            currentData = 0;
            currentDataPoints = 0;
            matr = [];
            matri = [];
          }
        } else {
          currentData++;
        }
      },
    );
    return ("ok");
  }
}
