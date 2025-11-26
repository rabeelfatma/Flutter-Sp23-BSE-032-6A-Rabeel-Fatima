import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'constantFile.dart';
class RepeatTextandIconWidget extends StatelessWidget {
  const RepeatTextandIconWidget({
    required this.iconData,
    required this.label,
  });

  final IconData iconData;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FaIcon(
          iconData,
          size: 80.0,
          color: Colors.white,
        ),
        const SizedBox(
          height: 15.0,
        ),
       Text(
          label,
          style: KLABELSTYLE,

        ),

      ],
    );
  }
}