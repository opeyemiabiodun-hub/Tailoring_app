cat << 'EOF' > /root/tailoring_app/lib/main.dart
import 'package:flutter/material.dart';

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

class Customer {
  final String name;
  final String phone;
  final String measurements;
  final String deliveryDate;
  final String paymentStatus;

  Customer({
    required this.name,
    required this.phone,
    required this.measurements,
    required this.deliveryDate,
    required this.paymentStatus,
  });
}

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final List<Customer> _customers = [
    Customer(
      name: 'Opeyemi Abiodun',
      phone: '08062100066',
      measurements: 'Chest: 40, Waist: 34, Length: 42',
      deliveryDate: '2026-11-10',
      paymentStatus: 'Pending',
    ),
    Customer(
      name: 'Fatima Bello',
      phone: '08098765432',
      measurements: 'Bust: 36, Waist: 30, Hips: 40',
      deliveryDate: '2026-11-15',
      paymentStatus: 'Deposit Made',
    ),
  ];

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final measurementsController = TextEditingController();
    final deliveryController = TextEditingController();
    String selectedStatus = 'Pending';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Client'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Customer Name')),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
                TextField(controller: measurementsController, decoration: const InputDecoration(labelText: 'Measurements')),
                TextField(controller: deliveryController, decoration: const InputDecoration(labelText: 'Delivery Date (YYYY-MM-DD)')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _customers.add(Customer(
                      name: nameController.text,
                      phone: phoneController.text,
                      measurements: measurementsController.text,
                      deliveryDate: deliveryController.text,
                      paymentStatus: selectedStatus,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tailoring Management', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      body: _customers.isEmpty
          ? const Center(child: Text('No clients added yet.'))
          : ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Phone: ${customer.phone}'),
                        Text('Measurements: ${customer.measurements}'),
                        Text('Delivery: ${customer.deliveryDate}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(customer.paymentStatus),
                      backgroundColor: customer.paymentStatus == 'Paid' ? Colors.green.shade100 : Colors.orange.shade100,
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
EOF
