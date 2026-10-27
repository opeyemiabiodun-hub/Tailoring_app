import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Tailoring Management', style: TextStyle(color: Colors.white)), backgroundColor: Colors.indigo),
        body: const Center(child: Text('Welcome to Tailoring Management', style: TextStyle(fontSize: 18))),
      ),
    );
  }
}
