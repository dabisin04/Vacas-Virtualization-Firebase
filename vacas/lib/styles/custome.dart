import 'package:flutter/material.dart';

InputDecoration customInputDecoration(String labelText) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: const TextStyle(color: Colors.blueGrey),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(
        color: Color.fromARGB(237, 206, 217, 224),
        width: 4.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(
        color: Colors.blue,
        width: 2.0,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
  );
}
