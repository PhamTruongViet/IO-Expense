class transaction_data {
  final int? id;
  // final String userId;
  final double amount;
  final String details;
  final String transactionType;
  final String category;
  final String subcategory;
  final String walletId;
  final String? filePath;
  final DateTime? date;

  transaction_data({
    this.id,
    required this.amount,
    required this.details,
    required this.transactionType,
    required this.category,
    required this.subcategory,
    required this.walletId,
    required this.filePath,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'amount': amount,
      'details': details,
      'transactionType': transactionType,
      'category': category,
      'subcategory': subcategory,
      'walletId': walletId,
      'filePath': filePath,
      'date': date?.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory transaction_data.fromMap(Map<String, dynamic> map) {
    return transaction_data(
      id: map['id'],
      amount: map['amount'],
      details: map['details'],
      transactionType: map['transactionType'],
      category: map['category'],
      subcategory: map['subcategory'],
      walletId: map['walletId'],
      filePath: map['filePath'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
    );
  }
}
