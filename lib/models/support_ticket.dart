class SupportTicket {
  final String id;
  final String subject;
  final String category;
  final String description;
  final String status;
  final String priority;
  final DateTime lastReplyAt;
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.category,
    required this.description,
    required this.status,
    required this.priority,
    required this.lastReplyAt,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['_id'],
      subject: json['subject'],
      category: json['category'],
      description: json['description'],
      status: json['status'],
      priority: json['priority'],
      lastReplyAt: DateTime.parse(json['lastReplyAt']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class TicketReply {
  final String id;
  final String content;
  final String senderRole;
  final String senderId;
  final DateTime createdAt;

  TicketReply({
    required this.id,
    required this.content,
    required this.senderRole,
    required this.senderId,
    required this.createdAt,
  });

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    return TicketReply(
      id: json['_id'],
      content: json['content'],
      senderRole: json['senderRole'],
      senderId: json['senderId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
