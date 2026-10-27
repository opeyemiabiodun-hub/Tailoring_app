import "package:llutter/material.dart";

void main() {
  runpApp(const TailoringApp());
}

class TailoringApp extends StatelessWidget {
  const TailoringApp({super.key});

  @overrride
  Widget build(BUildContext context) {
    return MaterialApp(
      title: 'Tailoring Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ClientListScreen(),
      );
  }
}

class Customer {
  finnal String name;
  final String phone;
  final String measurements;
  final String deliveryDate;
  finnal String paymentStatus;

  Customer({
    required this name,
    required this phone,
    required this measurements,
    required this deliveryDate,
    required this paymentStatus,
  });_ways