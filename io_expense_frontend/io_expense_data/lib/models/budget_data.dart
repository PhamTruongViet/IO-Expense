class budget_data {
  final int? id;
  final double amount;
  final String? details;
  final String category;
  final String? walletId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int isRepeat;

  budget_data({
    this.id,
    required this.amount,
    this.details,
    required this.category,
    this.walletId,
    required this.startDate,
    required this.endDate,
    required this.isRepeat,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'amount': amount,
      'details': details,
      'category': category,
      'walletId': walletId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isRepeat': isRepeat,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory budget_data.fromMap(Map<String, dynamic> map) {
    return budget_data(
      id: map['id'],
      amount: map['amount'],
      details: map['details'],
      category: map['category'],
      walletId: map['walletId'],
      startDate:
          map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      isRepeat: map['isRepeat'],
    );
  }
}
