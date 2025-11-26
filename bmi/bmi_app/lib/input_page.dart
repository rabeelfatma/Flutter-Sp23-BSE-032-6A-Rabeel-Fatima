import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'IconeTextFile.dart';
import 'ContainerFile.dart';
import 'constantFile.dart';

enum Gender {
  male,
  female,
}

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  Gender? selectGender;
  int sliderHeight = 180;
  int weight = 60;
  int age = 25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI Calculator"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          /// 1. Gender Row
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RepeatContainerCode(
                    onPressed: () {
                      setState(() {
                        selectGender = Gender.male;
                      });
                    },
                    colors: selectGender == Gender.male ? activeColor : deActiveColor,
                    cardWidget: const RepeatTextandIconWidget(
                      iconData: FontAwesomeIcons.mars,
                      label: 'MALE',
                    ),
                  ),
                ),
                Expanded(
                  child: RepeatContainerCode(
                    onPressed: () {
                      setState(() {
                        selectGender = Gender.female;
                      });
                    },
                    colors: selectGender == Gender.female ? activeColor : deActiveColor,
                    cardWidget: const RepeatTextandIconWidget(
                      iconData: FontAwesomeIcons.venus,
                      label: 'FEMALE',
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 2. Height Section — OVERFLOW FIXED
          Expanded(
            child: RepeatContainerCode(
              colors: const Color(0xFF1D1E33),
              cardWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'HEIGHT',
                    style: KLABELSTYLE,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        sliderHeight.toString(),
                        style: KNUMBERSTYLE,
                      ),
                      const Text(
                        'cm',
                        style: KLABELSTYLE,
                      ),
                    ],
                  ),

                  /// *** FIX: Expanded Slider to remove overflow ***
                  Expanded(
                    child: Slider(
                      value: sliderHeight.toDouble(),
                      min: 120.0,
                      max: 220.0,
                      activeColor: Colors.pink,
                      inactiveColor: Color(0xFF8D8E98),
                      onChanged: (double newValue) {
                        setState(() {
                          sliderHeight = newValue.round();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 3. Weight + Age Section
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RepeatContainerCode(
                    colors: const Color(0xFF1D1E33),
                    cardWidget: Container(),
                  ),
                ),
                Expanded(
                  child: RepeatContainerCode(
                    colors: const Color(0xFF1D1E33),
                    cardWidget: Container(),
                  ),
                ),
              ],
            ),
          ),

          /// 4. Bottom Button
          Container(
            color: bottomContainerColor,
            width: double.infinity,
            height: 60.0,
            child: const Center(
              child: Text(
                'CALCULATE',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
