import 'package:flutter/material.dart';

class WpaAuthDialog extends StatefulWidget {
  final String apName;

  const WpaAuthDialog({
    Key? key,
    required this.apName,
  }) : super(key: key);

  @override
  State<WpaAuthDialog> createState() => _WpaAuthDialogState();
}

class _WpaAuthDialogState extends State<WpaAuthDialog> {
  late final TextEditingController passwordTextController;
  late final FocusNode passwordTextFieldFocusNode;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    passwordTextController = TextEditingController();
    passwordTextFieldFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTrapArea(
      focusNode: passwordTextFieldFocusNode,
      child: AlertDialog(
        title: Text(widget.apName),
        contentPadding: const EdgeInsets.all(24.0).copyWith(bottom: 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordTextController,
              focusNode: passwordTextFieldFocusNode,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              obscureText: !showPassword,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              title: const Text("Show password"),
              value: showPassword,
              onChanged: (value) {
                setState(() => showPassword = value!);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: passwordTextController.text.length >= 8
                ? () => Navigator.pop(context, passwordTextController.text)
                : null,
            child: const Text("Connect"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    passwordTextController.dispose();
    super.dispose();
  }
}
