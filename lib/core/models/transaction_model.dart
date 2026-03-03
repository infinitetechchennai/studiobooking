class TransactionModel {
  final String id;
  final double advancePaid;
  final double totalAmount;
  final double remainingAmount;

  final String status;
  final String clientId;
  final String userEmail;
  final String vendorId;
  final DateTime createdAt;
  final String type;
  final String paymentGateway;
  final String bookingId;

  TransactionModel({
    required this.id,
    required this.advancePaid,
    required this.totalAmount, // NEW
    required this.remainingAmount, // NEW
    required this.status,
    required this.clientId,
    required this.userEmail,
    required this.vendorId,
    required this.createdAt,
    required this.type,
    required this.paymentGateway,
    required this.bookingId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': advancePaid,
      'totalAmount': totalAmount, // NEW
      'remainingAmount': remainingAmount, // NEW
      'status': status,
      'clientId': clientId,
      'userEmail': userEmail,
      'vendorId': vendorId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'type': type,
      'paymentGateway': paymentGateway,
      'bookingId': bookingId,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      advancePaid: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      clientId: json['clientId'] as String,
      userEmail: json['userEmail'] as String,
      vendorId: json['vendorId'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      type: json['type'] as String,
      paymentGateway: json['paymentGateway'] as String,
      bookingId: json['bookingId'] as String,
    );
  }
}
