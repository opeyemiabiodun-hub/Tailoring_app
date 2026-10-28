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
      title: 'Tailor Shop Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B4D3E)),
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// --- 1. WELCOME / AUTH SCREEN ---
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B4D3E), Color(0xFF0F2E24)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('👔✂️', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Business. Your Phone. No Paper.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                'Customers, measurements, orders and invoices — all in one simple mobile app.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFFD1D8D4), height: 1.4),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1B4D3E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                    );
                  },
                  child: const Text('Open Workspace', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- MAIN NAVIGATION CONTAINER ---
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
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), activeIcon: Icon(Icons.add_box), label: 'New Order'),
        ],
      ),
    );
  }
}

// --- 2. DASHBOARD TAB ---
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  double totalIncome = 0;
  double totalOutstanding = 0;
  int activeOrdersCount = 0;
  int dueThisWeekCount = 0;

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
    int dueWeek = 0;
    final today = DateTime.now();
    final nextWeek = today.add(const Duration(days: 7));

    for (var o in orders) {
      income += o.depositPaid;
      outstanding += o.balanceRemaining;
      if (o.deliveryDate.isAfter(today) && o.deliveryDate.isBefore(nextWeek)) {
        dueWeek++;
      }
    }

    setState(() {
      totalIncome = income;
      totalOutstanding = outstanding;
      activeOrdersCount = orders.length;
      dueThisWeekCount = dueWeek;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tailor Shop', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Workspace • Starter Plan', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        backgroundColor: const Color(0xFF1B4D3E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Business Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics,
              childAspectRatio: 1.5,
              children: [
                _StatCard(title: 'Income (Net)', value: '₦${totalIncome.toStringAsFixed(0)}', color: const Color(0xFF1B4D3E)),
                _StatCard(title: 'Outstanding', value: '₦${totalOutstanding.toStringAsFixed(0)}', color: const Color(0xFFC0392B)),
                _StatCard(title: 'Active Orders', value: '$activeOrdersCount', color: const Color(0xFF2980B9)),
                _StatCard(title: 'Due This Week', value: '$dueThisWeekCount', color: const Color(0xFFD35400)),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF666666), fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// --- 3. CUSTOMERS TAB ---
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
        title: const Text('Customer Directory', style: TextStyle(color: Colors.white, fontSize: 18)),
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
                'No customers registered yet.\nUse the New Order tab to add clients.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            );
          }

          final clients = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 3)],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1B4D3E),
                    child: Text(client.fullName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(client.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${client.phoneNumber} • ${client.gender}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- 4. NEW ORDER / INTAKE TAB ---
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

  final List<String> _maleFields = [
    'Chest', 'Shoulder', 'Sleeve Length', 'Neck', 'Stomach / Waist', 
    'Top Length', 'Trouser Waist', 'Hip', 'Thigh', 'Trouser Length'
  ];

  final List<String> _femaleFields = [
    'Bust', 'Under Bust', 'Waist', 'Hips', 'Shoulder', 
    'Sleeve Length', 'Blouse Length', 'Skirt / Gown Length', 'Round Sleeve'
  ];

  final Map<String, TextEditingController> _measurementControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllersForGender(_selectedGender);
  }

  void _initializeControllersForGender(String gender) {
    _measurementControllers.clear();
    List<String> activeFields = gender == 'Male' ? _maleFields : _femaleFields;
    for (var field in activeFields) {
      _measurementControllers[field] = TextEditingController();
    }
  }

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
            outfitPart: _selectedGender,
            fieldName: entry.key,
            measurementValue: val,
          );
          await DatabaseHelper.instance.insertMeasurement(measurement);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order and measurements saved successfully!')),
      );

      _formKey.currentState!.reset();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentFields = _selectedGender == 'Male' ? _maleFields : _femaleFields;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Customer Order', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF1B4D3E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer & Order Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E))),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Client Full Name', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Client Gender', border: OutlineInputBorder()),
                  items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedGender = val!;
                      _initializeControllersForGender(_selectedGender);
                    });
                  },
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
                Text('$_selectedGender Body Measurements (Inches)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E))),
                const SizedBox(height: 10),
                ...currentFields.map((field) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: TextFormField(
                    controller: _measurementControllers[field],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: field, border: const OutlineInputBorder(), isDense: true),
                  ),
                )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4D3E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: _saveOrderForm,
                    child: const Text('Save Order & Measurements', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
