import 'package:flutter/material.dart';
import '../models/tailor_models.dart';
import '../models/database_helper.dart'; // <-- Add this import

// ... inside your _ClientIntakeFormState class:

  void _saveClientForm() async { // Make the method async
    if (_formKey.currentState!.validate()) {
      String uniqueClientId = DateTime.now().millisecondsSinceEpoch.toString();

      Client newClient = Client(
        clientId: uniqueClientId,
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
        gender: _selectedGender,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
      );

      // Save Client to database using DatabaseHelper[span_1](start_span)[span_1](end_span)
      await DatabaseHelper.instance.insertClient(newClient);

      // Collect and save Measurements to database[span_2](start_span)[span_2](end_span)
      _measurementControllers.forEach((fieldName, controller) async {
        if (controller.text.isNotEmpty) {
          double val = double.tryParse(controller.text) ?? 0.0;
          Measurement measurement = Measurement(
            measurementId: DateTime.now().millisecondsSinceEpoch.toString() + fieldName,
            clientId: uniqueClientId,
            outfitPart: _selectedOutfitType,
            fieldName: fieldName,
            measurementValue: val,
          );
          await DatabaseHelper.instance.insertMeasurement(measurement);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Client ${newClient.fullName} saved to database!')),
      );

      _formKey.currentState!.reset();
    }
  }
