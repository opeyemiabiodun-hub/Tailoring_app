class Client {
  final String clientId;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final String? email;
  final String? notes;

  Client({
    required this.clientId,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    this.email,
    this.notes,
  });

  // Convert Client to Map for saving
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'email': email,
      'notes': notes,
    };
  }

  // Create Client from Map when loading
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      clientId: map['clientId'],
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      gender: map['gender'],
      email: map['email'],
      notes: map['notes'],
    );
  }
}

class Measurement {
  final String measurementId;
  final String clientId;
  final String outfitPart;
  final String fieldName;
  final double measurementValue;

  Measurement({
    required this.measurementId,
    required this.clientId,
    required this.outfitPart,
    required this.fieldName,
    required this.measurementValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'measurementId': measurementId,
      'clientId': clientId,
      'outfitPart': outfitPart,
      'fieldName': fieldName,
      'measurementValue': measurementValue,
    };
  }
}

class Order {
  final String orderId;
  final String clientId;
  final String orderDescription;
  final String? stylePhotoPath;
  final String? fabricPhotoPath;
  final double totalAmount;
  final double depositPaid;
  final double balanceRemaining;
  final DateTime deliveryDate;
  String orderStatus;

  Order({
    required this.orderId,
    required this.clientId,
    required this.orderDescription,
    this.stylePhotoPath,
    this.fabricPhotoPath,
    required this.totalAmount,
    required this.depositPaid,
    required this.balanceRemaining,
    required this.deliveryDate,
    required this.orderStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'clientId': clientId,
      'orderDescription': orderDescription,
      'stylePhotoPath': stylePhotoPath,
      'fabricPhotoPath': fabricPhotoPath,
      'totalAmount': totalAmount,
      'depositPaid': depositPaid,
      'balanceRemaining': balanceRemaining,
      'deliveryDate': deliveryDate.toIso8601String(),
      'orderStatus': orderStatus,
    };
  }
}
