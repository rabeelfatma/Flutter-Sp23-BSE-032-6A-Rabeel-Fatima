import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class RepeatContainerCode extends StatelessWidget {
  const RepeatContainerCode({
    Key? key,
    required this.colors,
    this.cardWidget,
    this.onPressed,
  }) : super(key: key);

  final Color colors;
  final Widget? cardWidget;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(10.0),

        height: double.infinity,

        decoration: BoxDecoration(
          color: colors,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: cardWidget ?? const SizedBox(),
      ),
    );
  }
}
