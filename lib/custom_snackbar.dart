import 'package:flutter/material.dart';

SnackBar snackBar(
    String text, {
      bool? error,
    }) {
  return SnackBar(
    content: Text(text),
    action: SnackBarAction(
      label: 'X',
      textColor: Colors.white,
      onPressed: () {},
    ),
    backgroundColor: error == null ? Colors.green : Colors.red,
    behavior: SnackBarBehavior.fixed,
    duration: const Duration(seconds: 5),
  );
}

errorSnackBar({required context, String? text}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    snackBar(
      text ?? "Error",
      error: true,
    ),
  );
}

