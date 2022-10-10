import 'package:flutter/material.dart';

class UnsupportedNetworkDialog extends StatelessWidget {
  const UnsupportedNetworkDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text("Unsupported network"),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text("Close"),
        )
      ],
    );
  }
}
