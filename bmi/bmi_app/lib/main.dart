import 'package:flutter/material.dart';
import 'input_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:InputPage(),
      debugShowCheckedModeBanner: false,
      //option1
      // theme: ThemeData(
      //   //colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      //   primaryColor: Color(0xFF0A0E21),
      //   scaffoldBackgroundColor:Color(0xFF0A0E21),
      //   textTheme: TextTheme(
      //       bodyMedium: TextStyle(color: Colors.white)
      //   ),
      // ),
      //option 2
        theme: ThemeData.dark().copyWith(
          primaryColor: Color(0xFF0A0E21),
          scaffoldBackgroundColor:Color(0xFF0A0E21),
        ),
    );
  }
}



