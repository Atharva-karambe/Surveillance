import 'package:flutter/material.dart';
import 'package:consurveillance/services/loclat.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {


  final myController = TextEditingController();
  final mController = TextEditingController();


  @override
  void initState() {
    print("hi");
    super.initState();
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
            child: TextField(
              controller: myController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter your id",
                hintStyle: TextStyle(color: Colors.white),
                labelText: 'ID',
                labelStyle: TextStyle(
                  color: Color.fromARGB(
                      255, 144, 143, 143), // set label text color here
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
            child: TextField(
              controller: mController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter your code",
                hintStyle: TextStyle(color: Color.fromARGB(255, 144, 143, 143)),
                labelText: 'Room code',
                labelStyle: TextStyle(
                  color: Colors.white, // set label text color here
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        Colors.amber, // Change the text color of the button
                  ),
                  onPressed: () {
                    if ((myController.text != "") && (mController.text != "")) {
                      Navigator.pushNamed(context, "/test", arguments: {
                        "id": myController.text,
                        "roomcode": mController.text
                      });
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text('Start meet', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
