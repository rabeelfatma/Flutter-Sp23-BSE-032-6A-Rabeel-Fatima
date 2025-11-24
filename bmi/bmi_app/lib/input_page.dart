import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});
  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BMI Calculator"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Body Text Example', // Your text goes here
              style: TextStyle(
                fontSize: 24.0,
                // Setting color explicitly ensures it is visible
                color: Colors.white,
              ),
            ),
          ],

        ),
      ),
    );
  }
}