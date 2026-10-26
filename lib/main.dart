import 'package:flutter/material.dart';

void main() {
  runApp(const TailoringApp());
}

class TailoringApp extends StatelessWidget {
  const TailoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tailoring Manager',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const CustomerListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CustomerRecord {
  String name;
  String phone;
  String measurements;
  String paymentStatus;
  String deliveryDate;

  CustomerRecord({
    required this.name,
    required this.phone,
    required this.measurements,
    required this.paymentStatus,
    required this.deliveryDate,
  });
}

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final List<CustomerRecord> _customers = [
    CustomerRecord(
      name: 'Adebayo Johnson',
      phone: '08031234567',
      measurements: 'Chest: 40, Waist: 34, Length: 42',
      paymentStatus: 'Paid',
      deliveryDate: '2026-11-10',
    ),
    CustomerRecord(
      name: 'Fatima Bello',
      phone: '08098765432',
      measurements: 'Bust: 36, Waist: 30, Hips: 40',
      paymentStatus: 'Pending',
      deliveryDate: '2026-11-15',
    ),
  ];

  void _addCustomer(CustomerRecord customer) {
    setState(() {
      _customers.add(customer);
    });
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final measurementsController = TextEditingController();
    String paymentStatus = 'Pending';
    final deliveryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Customer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Customer Name')),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone),
                TextField(controller: measurementsController, decoration: const InputDecoration(labelText: 'Measurements (Chest, Waist, etc.)')),
                TextField(controller: deliveryController, decoration: const InputDecoration(labelText: 'Delivery Date (YYYY-MM-DD)')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: paymentStatus,
                  items: ['Pending', 'Paid', 'Deposit Made']
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) => paymentStatus = value!,
                  decoration: const InputDecoration(labelText: 'Payment Status'),
                ),
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
                  _addCustomer(CustomerRecord(
                    name: nameController.text,
                    phone: phoneController.text,
                    measurements: measurementsController.text,
                    paymentStatus: paymentStatus,
                    deliveryDate: deliveryController.text,
                  ));
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
        title: const Text('Tailoring Management'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _customers.isEmpty
          ? const Center(child: Text('No customers added yet.'))
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
