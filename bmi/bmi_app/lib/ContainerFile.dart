import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class RepeatContainerCode extends StatelessWidget {
  const RepeatContainerCode({
    Key? key,
    required this.colors,
    this.cardWidget,
  }) : super(key: key);

  final Color colors;
  final Widget? cardWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),

      // FIX → Force it to expand fully so empty ones also appear
      height: double.infinity,

      decoration: BoxDecoration(
        color: colors,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: cardWidget ?? const SizedBox(),
    );
  }
}
