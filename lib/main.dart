import 'package:flutter/material.dart';
import 'models/tailor_models.dart';
import 'models/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B4D3E)),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const ClientListTab(),
    const AddOrderTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1B4D3E),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'New Order'),
        ],
      ),
    );
  }
}

// --- DASHBOARD TAB ---
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  double totalIncome = 0;
  double totalOutstanding = 0;
  int activeOrdersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    List<Order> orders = await DatabaseHelper.instance.database.then((db) async {
      final result = await db.query('orders');
      return result.map((json) => Order.fromMap(json)).toList();
    }).catchError((_) => <Order>[]);

    double income = 0;
    double outstanding = 0;
    for (var o in orders) {
      income += o.depositPaid;
      outstanding += o.balanceRemaining;
    }

    setState(() {
      totalIncome = income;
      totalOutstanding = outstanding;
      activeOrdersCount = orders.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tailor Shop Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B4D3E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _StatCard(title: 'Total Income', value: '₦$totalIncome', color: Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'Outstanding', value: '₦$totalOutstanding', color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(title: 'Active Orders', value: '$activeOrdersCount', color: Colors.blue)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

// --- CLIENT LIST TAB ---
class ClientListTab extends StatefulWidget {
  const ClientListTab({super.key});

  @override
  State<ClientListTab> createState() => _ClientListTabState();
}

class _ClientListTabState extends State<ClientListTab> {
  late Future<List<Client>> _clientListFuture;

  @override
  void initState() {
    super.initState();
    _refreshClients();
  }

  void _refreshClients() {
    setState(() {
      _clientListFuture = DatabaseHelper.instance.getClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Directory', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B4D3E),
      ),
      body: FutureBuilder<List<Client>>(
        future: _clientListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading clients'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No clients registered yet.\nUse the New Order tab to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            );
          }

          final clients = snapshot.data!;
          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1B4D3E),
                    child: Text(client.fullName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(client.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${client.phoneNumber} • ${client.gender}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- ADD ORDER & INTAKE TAB ---
class AddOrderTab extends StatefulWidget {
  const AddOrderTab({super.key});

  @override
  State<AddOrderTab> createState() => _AddOrderTabState();
}

class _AddOrderTabState extends State<AddOrderTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalController = TextEditingController();
  final _depositController = TextEditingController();
  
  String _selectedGender = 'Male';
  String _selectedOutfit = 'Agbada / Top';

  final Map<String, TextEditingController> _measurementControllers = {
    'Chest': TextEditingController(),
    'Waist': TextEditingController(),
    'Shoulder': TextEditingController(),
    'Length': TextEditingController(),
  };

  void _saveOrderForm() async {
    if (_formKey.currentState!.validate()) {
      String uniqueClientId = DateTime.now().millisecondsSinceEpoch.toString();

      Client newClient = Client(
        clientId: uniqueClientId,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender,
      );

      await DatabaseHelper.instance.insertClient(newClient);

      double total = double.tryParse(_totalController.text) ?? 0.0;
      double deposit = double.tryParse(_depositController.text) ?? 0.0;
      double balance = total - deposit;

      Order newOrder = Order(
        orderId: DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: uniqueClientId,
        orderDescription: _descriptionController.text.trim(),
        totalAmount: total,
        depositPaid: deposit,
        balanceRemaining: balance,
        deliveryDate: DateTime.now().add(const Duration(days: 7)),
        orderStatus: 'Pending',
      );

      await DatabaseHelper.instance.insertOrder(newOrder);

      for (var entry in _measurementControllers.entries) {
        if (entry.value.text.isNotEmpty) {
          double val = double.tryParse(entry.value.text) ?? 0.0;
          Measurement measurement = Measurement(
            measurementId: '${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
            clientId: uniqueClientId,
            outfitPart: _selectedOutfit,
            fieldName: entry.key,
            measurementValue: val,
          );
          await DatabaseHelper.instance.insertMeasurement(measurement);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order and client measurements saved successfully!')),
      );

      _formKey.currentState!.reset();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Client Order', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B4D3E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Client Full Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Style Description / Notes', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Total Amount (₦)', border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _depositController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Deposit Paid (₦)', border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Measurements (Inches)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E))),
              const SizedBox(height: 10),
              ..._measurementControllers.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: TextFormField(
                  controller: entry.value,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: entry.key, border: const OutlineInputBorder()),
                ),
              )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4D3E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _saveOrderForm,
                  child: const Text('Save Order & Measurements', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
