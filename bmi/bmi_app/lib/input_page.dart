import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'IconeTextFile.dart';
import 'ContainerFile.dart';
const activeColor=Color(0xFF1D1E33);
const deActiveColor=Color(0xFF111328);
const Color activeCardColor = Color(0xFF1D1E33);
const Color bottomContainerColor = Color(0xFFEB1555);
enum Gender{
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
  // Color maleColor = deActiveColor;
  // Color feMaleColor = deActiveColor;
  // void updateColor(Gender gendertype){
  // if(gendertype==Gender.male){
  //   maleColor = activeColor;
  //   feMaleColor = deActiveColor;
  // }
  // if(gendertype==Gender.female){
  //   maleColor = deActiveColor;
  //   feMaleColor = activeColor;
  // }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI Calculator"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        selectGender=Gender.male;

                      });
                    },
                    child: RepeatContainerCode(
                      colors: selectGender==Gender.male?activeColor:deActiveColor,
                      cardWidget: const RepeatTextandIconWidget(
                        iconData: FontAwesomeIcons.male,
                        label: 'MALE',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        selectGender=Gender.female;
                      });
                    },
                    child: RepeatContainerCode(
                      colors: selectGender==Gender.female?activeColor:deActiveColor,
                      cardWidget: const RepeatTextandIconWidget(
                        iconData: FontAwesomeIcons.female,
                        label: 'FEMALE',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RepeatContainerCode(
              colors: const Color(0xFF1D1E33),
            ),
          ),

          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RepeatContainerCode(
                    colors: const Color(0xFF1D1E33),
                  ),
                ),
                Expanded(
                  child: RepeatContainerCode(
                    colors: const Color(0xFF1D1E33),
                  ),
                ),
              ],
            ),
          ),

          Container(
            color: bottomContainerColor,
            margin: const EdgeInsets.only(top: 10.0),
            width: double.infinity,
            height: 60.0,
          ),
        ],
      ),
    );
  }
}
