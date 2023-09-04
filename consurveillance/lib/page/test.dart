import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:consurveillance/services/loclat.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

const serverUrl = 'https://flippantfocusedreciprocal.atharvakarambe.repl.co/';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  late Map<String, dynamic> dataa;
  Location location = Location();
  Locationstatus locationstatus = Locationstatus();
  LocationData? currentLocation;
  late io.Socket socket;
  String host = "";
  String feed = "0";

  Future<void> fetchAndSendFrames() async {
    while (true) {
      try {
        // Replace 'IP_CAMERA_URL' with the URL of your IP camera
        final response =
            await http.get(Uri.parse('http://192.168.1.8:8080/photoaf.jpg'));

        if (response.statusCode == 200) {
          // Convert the response body (image data) to bytes
          Uint8List imageData = response.bodyBytes;

          // Send the image data to the socket
          socket.emit(
              'feed', {'id': dataa["id"], "image": imageData, "host": host});
        } else {
          print('Failed to fetch the frame: ${response.statusCode}');
          break;
        }
      } catch (e) {
        print('Error fetching frame: $e');
        break;
      }
    }
  }

  Future<void> sendData(
    soc,
    da,
  ) async {
    sensor.getgyro();
    sensor.getacc(soc, da, host);
  }

  Senser sensor = Senser();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataa =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    });

    // Connect to the server
    socket = io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // Listen for 'connect' event
    socket.on('connect', (_) {
      socket.emit("connect_client", {"roomcode": dataa["roomcode"]});
      print('Connected to the server');
    });

    // Listen for 'connect_error' event
    socket.on('connect_error', (_) {
      print('Connection error');
    });

    // Listen for 'host_key' event
    socket.on('host_key', (data) {
      setState(() {
        host = data;
      });
      sendData(socket, dataa["id"]);
      fetchAndSendFrames();
    });

    // Periodically check for the 'feed' condition and emit 'feed' event
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (host != "") {
        currentLocation = await location.getLocation();
        socket.emit('data', {
          'id': dataa["id"],
          "lon": currentLocation!.latitude,
          "lan": currentLocation!.longitude,
          "host": host
        });
        setState(() {});
      }
    });

    // Connect to the server
    socket.connect();
  }

  @override
  void dispose() {
    // Disconnect from the server when the widget is disposed
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Room"),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: currentLocation == null
                  ? CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Latitude: ${currentLocation!.latitude}',
                            style:
                                TextStyle(fontSize: 25, color: Colors.amber)),
                        Text(
                          'Longitude: ${currentLocation!.longitude}',
                          style: TextStyle(fontSize: 25, color: Colors.amber),
                        ),
                        SizedBox(
                          width: 150.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors
                                  .amber, // Change the text color of the button
                            ),
                            onPressed: () {
                              socket.emit('marker', {
                                'id': dataa["id"],
                                "lon": currentLocation!.latitude,
                                "lan": currentLocation!.longitude,
                                "host": host
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text('Marker',
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 150.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color.fromARGB(255, 255, 15,
                                  7), // Change the text color of the button
                            ),
                            onPressed: () {
                              socket.emit(
                                  'alert', {'id': dataa["id"], "host": host});
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text('Alert Signal',
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                        ),
                      ],
                    )),
        ],
      ),
    ); // Replace with your UI
  }
}
