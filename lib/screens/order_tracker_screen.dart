import 'package:flutter/material.dart';
import '../models/tailor_models.dart';
import '../models/database_helper.dart'; // <-- Add this import

// ... inside your _OrderTrackerScreenState class:

  void _saveOrder() async { // Make the method async
    if (_formKey.currentState!.validate()) {
      double total = double.tryParse(_totalAmountController.text) ?? 0.0;
      double deposit = double.tryParse(_depositController.text) ?? 0.0;
      double balance = total - deposit;

      Order newOrder = Order(
        orderId: DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: widget.clientId,
        orderDescription: _descriptionController.text,
        totalAmount: total,
        depositPaid: deposit,
        balanceRemaining: balance,
        deliveryDate: _selectedDeliveryDate,
        orderStatus: _selectedStatus,
      );

      // Save Order to database using DatabaseHelper[span_3](start_span)[span_3](end_span)
      await DatabaseHelper.instance.insertOrder(newOrder);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order saved to database! Balance remaining: $balance')),
      );

      _formKey.currentState!.reset();
    }
  }
