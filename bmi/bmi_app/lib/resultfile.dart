import 'package:flutter/material.dart';
import 'constantFile.dart';
import 'containerFile.dart';
import 'input_page.dart';


class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI Result"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15.0),
              alignment: Alignment.center,
              child: const Text(
                'Your Result',
                style: KTITLESTYLE2,
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child: RepeatContainerCode(
              colors: activeCardColor,
              cardWidget: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Normal',
                    textAlign: TextAlign.center,
                    style: kResultText,
                  ),
                  Text(
                    '18.3',
                    textAlign: TextAlign.center,
                    style: kBMIText,
                  ),
                  Text(
                    'BMI is low so you should work more',
                    textAlign: TextAlign.center,
                    style: kbodyTextStyle,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                color: bottomContainerColor,
                width: double.infinity,
                height: 60.0,
                child: const Center(
                  child: Text(
                    'RE-CALCULATE',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}