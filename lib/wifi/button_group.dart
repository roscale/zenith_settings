import 'package:flutter/material.dart';
import 'package:zenith_settings/util.dart';

class ButtonGroup extends StatelessWidget {
  final List<ButtonGroupChild> children;

  const ButtonGroup({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> widgets = children.map((child) {
      Widget button = _buildButton(child);

      if (child == children.first) {
        button = ClipRRect(
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
          child: button,
        );
      } else if (child == children.last) {
        button = ClipRRect(
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
          child: button,
        );
      }

      return Expanded(child: button);
    });

    widgets = widgets.interleave(const VerticalDivider(width: 1));

    return Row(
      children: widgets.toList(),
    );
  }

  Widget _buildButton(ButtonGroupChild child) {
    return TextButton(
      onPressed: child.onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Colors.blue.withOpacity(0.1)),
        overlayColor: MaterialStatePropertyAll(Colors.blue.withOpacity(0.05)),
        elevation: const MaterialStatePropertyAll(0),
        padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 20)),
        shape: const MaterialStatePropertyAll(RoundedRectangleBorder()),
      ),
      child: child.widget,
    );
  }
}

class ButtonGroupChild {
  final Widget widget;
  final VoidCallback onPressed;

  ButtonGroupChild({required this.widget, required this.onPressed});
}
