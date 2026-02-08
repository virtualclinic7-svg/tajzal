enum PaymentStatus {
  pending('PENDING', 'قيد الانتظار'),
  completed('COMPLETED', 'مكتمل'),
  failed('FAILED', 'فشل'),
  refunded('REFUNDED', 'مسترد');

  final String value;
  final String arabicLabel;
  const PaymentStatus(this.value, this.arabicLabel);

  static PaymentStatus? fromString(String? status) {
    if (status == null) return null;
    return PaymentStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => PaymentStatus.pending,
    );
  }
}

enum PaymentMethod {
  creditCard('CREDIT_CARD', 'بطاقة ائتمانية'),
  debitCard('DEBIT_CARD', 'بطاقة مدفوعة مسبقاً'),
  digitalWallet('DIGITAL_WALLET', 'محفظة رقمية');

  final String value;
  final String arabicLabel;
  const PaymentMethod(this.value, this.arabicLabel);

  static PaymentMethod? fromString(String? method) {
    if (method == null) return null;
    return PaymentMethod.values.firstWhere(
      (e) => e.value == method,
      orElse: () => PaymentMethod.creditCard,
    );
  }
}

class Payment {
  final String id;
  final String appointmentId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod paymentMethod;
  final String? intentId;
  final String? transactionId;
  final DateTime? paidAt;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.appointmentId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    this.intentId,
    this.transactionId,
    this.paidAt,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? json['_id'] ?? '',
      appointmentId: json['appointmentId']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'SAR',
      status: PaymentStatus.fromString(json['status']) ?? PaymentStatus.pending,
      paymentMethod: PaymentMethod.fromString(json['paymentMethod']) ?? PaymentMethod.creditCard,
      intentId: json['intentId']?.toString(),
      transactionId: json['transactionId']?.toString(),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      failureReason: json['failureReason'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'amount': amount,
      'currency': currency,
      'status': status.value,
      'paymentMethod': paymentMethod.value,
      'intentId': intentId,
      'transactionId': transactionId,
      'paidAt': paidAt?.toIso8601String(),
      'failureReason': failureReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PaymentIntentResponse {
  final String intentId;
  final String clientSecret;
  final double amount;
  final String currency;
  final PaymentStatus status;

  PaymentIntentResponse({
    required this.intentId,
    required this.clientSecret,
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      intentId: json['intentId'] ?? '',
      clientSecret: json['clientSecret'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'SAR',
      status: PaymentStatus.fromString(json['status']) ?? PaymentStatus.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intentId': intentId,
      'clientSecret': clientSecret,
      'amount': amount,
      'currency': currency,
      'status': status.value,
    };
  }
}




