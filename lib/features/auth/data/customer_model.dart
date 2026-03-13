class CustomerModel {
  final int? id;
  final String firstName;
  final String? lastName;
  final String phone;
  final String? email;
  final int? storeId; // Links to Java @JoinColumn(name = "store_id")

  CustomerModel({
    this.id,
    required this.firstName,
    this.lastName,
    required this.phone,
    this.email,
    this.storeId,
  });

  // This will be used later when the Java API returns JSON
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      email: json['email'],
      storeId: json['storeId'],
    );
  }

  // This will be used to send data TO  Java backend
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'storeId': storeId,
    };
  }
}