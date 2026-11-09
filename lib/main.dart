import 'package:flutter/material.dart';

import 'features/write_data/write_data_screen.dart';

void main() {
  runApp(const HubsQaApp());
}

class HubsQaApp extends StatelessWidget {
  const HubsQaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hubs QA App',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const WriteDataScreen(),
    );
  }
}
