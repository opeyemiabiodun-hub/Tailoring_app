import 'package:flutter/material.dart';
import '../models/tailor_models.dart';
import '../models/database_helper.dart';
import 'client_detail_screen.dart';

class ClientListScreen extends StatefulWidget {
  @override
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
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
        title: Text('Registered Clients'),
      ),
      body: FutureBuilder<List<Client>>(
        future: _clientListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading clients'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No clients registered yet.\nRegister a client to see them here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }

          final clients = snapshot.data!;
          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(client.fullName[0].toUpperCase()),
                  ),
                  title: Text(client.fullName, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${client.phoneNumber} • ${client.gender}'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientDetailScreen(client: client),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
