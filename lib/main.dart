import 'package:flutter/material.dart';
import 'screens/client_list_screen.dart';

void main() {
  runApp(const TailoringApp());
}

class TailoringApp extends StatelessWidget {
  const TailoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tailoring Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ClientListScreen(),
    );
  }
}
