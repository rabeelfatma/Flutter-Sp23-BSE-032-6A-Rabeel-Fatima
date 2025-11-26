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
  int sliderWeight = 60;
  int sliderAge = 20;

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

          /// 2. Height Section
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

                  Expanded(
                    child: Slider(
                      value: sliderHeight.toDouble(),
                      min: 120.0,
                      max: 220.0,
                      activeColor: Colors.pink,
                      inactiveColor: const Color(0xFF8D8E98),
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

          /// 3. Weight + Age Section (Final Fixed Structure)
          Expanded(
            child: Row(
              children: <Widget>[
                // --- WEIGHT SECTION ---
                Expanded(
                  child: RepeatContainerCode(
                    colors: const Color(0xFF1D1E33),
                    cardWidget: SingleChildScrollView(
                      // FIX: Wrap the Column in Padding, not the property of Column
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0), // Padding to lift content
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'WEIGHT',
                              style: KLABELSTYLE,
                            ),
                            Text(
                              sliderWeight.toString(),
                              style: KNUMBERSTYLE,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  RoundIcon(
                                    iconData: FontAwesomeIcons.minus,
                                    onPress: () {
                                      setState(() {
                                        if (sliderWeight > 1) {
                                          sliderWeight--;
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 10.0),
                                  RoundIcon(
                                    iconData: FontAwesomeIcons.plus,
                                    onPress: () {
                                      setState(() {
                                        sliderWeight++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // --- AGE SECTION ---
                Expanded(
                  child: RepeatContainerCode(
                    colors: const Color(0xFF1D1E33),
                    cardWidget: SingleChildScrollView(
                      // FIX: Wrap the Column in Padding, not the property of Column
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0), // Padding to lift content
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'AGE',
                              style: KLABELSTYLE,
                            ),
                            Text(
                              sliderAge.toString(),
                              style: KNUMBERSTYLE,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  RoundIcon(
                                    iconData: FontAwesomeIcons.minus,
                                    onPress: () {
                                      setState(() {
                                        if (sliderAge > 1) {
                                          sliderAge--;
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 10.0),
                                  RoundIcon(
                                    iconData: FontAwesomeIcons.plus,
                                    onPress: () {
                                      setState(() {
                                        sliderAge++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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


class RoundIcon extends StatelessWidget {
  final IconData iconData;
  final Function onPress;

  const RoundIcon({
    super.key,
    required this.iconData,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () {
        onPress();
      },
      constraints: const BoxConstraints.tightFor(
        width: 53.0,
        height: 53.0,
      ),
      shape: const CircleBorder(),
      fillColor: const Color(0xFF4C4F5E),
      elevation: 6.0,
      child: Icon(
        iconData,
        color: Colors.white,
      ),
    );
  }
}