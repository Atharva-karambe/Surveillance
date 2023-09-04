import 'package:flutter/material.dart';
import 'package:consurveillance/services/loclat.dart';
import 'package:location/location.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

const URL = "https://abhiraksha-project.atharvakarambe.repl.co/location";
const URLa = 'http://flippantfocusedreciprocal.atharvakarambe.repl.co/';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Map<String, dynamic> dataa;
  Location location = Location();
  Locationstatus locationstatus = Locationstatus();
  LocationData? currentLocation;
  Timer? _timer;
  Locationtoserver locationtoserver = Locationtoserver(url: URL);
  late final io.Socket socket;

  void initializeSocket() {
    // Initialize socket.io and connect to the server
    socket = io.io(URLa);
    socket.onConnect((_) {
      print('Connected to server');
      // You can emit events or perform other actions upon connecting.
    });

    socket.on('host_key', (data) {
      print('Host Key: $data');
      // Handle the host_key event data as needed.
    });

    socket.on('command', (data) {
      print('Command: $data');
      // Handle the command event data as needed.
    });

    socket.connect();
  }

  Future<void> locationLocationPermition() async {
    if ((locationstatus.checkLocationPermission(location)) != false) {
      currentLocation = await location.getLocation();
      setState(() {});
    } else {
      Navigator.pop(context);
    }
  }

  void sendData() async {
    locationtoserver.getData(currentLocation!.longitude,
        currentLocation!.latitude, dataa["roomcode"], dataa["id"]);
  }

  Future<void> getLocation() async {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      currentLocation = await location.getLocation();
      sendData();
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    locationLocationPermition();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataa = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      getLocation();
      // Access the data here
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
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
                      ],
                    )),
        ],
      ),
    );
  }
}
