import 'package:flutter/material.dart';
import '../models/tailor_models.dart';
import '../models/database_helper.dart';

class ClientDetailScreen extends StatefulWidget {
  final Client client;

  ClientDetailScreen({required this.client});

  @override
  _ClientDetailScreenState createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  late Future<List<Measurement>> _measurementsFuture;

  @override
  void initState() {
    super.initState();
    _measurementsFuture = DatabaseHelper.instance.getMeasurementsForClient(widget.client.clientId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.fullName),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Phone: ${widget.client.phoneNumber}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Gender: ${widget.client.gender}', style: TextStyle(fontSize: 16)),
                    if (widget.client.email != null && widget.client.email!.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text('Email: ${widget.client.email}', style: TextStyle(fontSize: 16)),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Saved Measurements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Measurement>>(
                future: _measurementsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading measurements'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No measurements recorded for this client.',
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                    );
                  }

                  final measurements = snapshot.data!;
                  return ListView.builder(
                    itemCount: measurements.length,
                    itemBuilder: (context, index) {
                      final m = measurements[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(m.fieldName, style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Outfit Part: ${m.outfitPart}'),
                          trailing: Text(
                            '${m.measurementValue}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
