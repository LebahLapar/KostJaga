// KostRoom Model
class KostRoom {
  final String id;
  final String roomNumber;
  final String type; // single, double, shared
  final double price;
  final String status; // available, occupied, maintenance
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;

  KostRoom({
    required this.id,
    required this.roomNumber,
    required this.type,
    required this.price,
    required this.status,
    this.description,
    this.imageUrl,
    required this.createdAt,
  });

  factory KostRoom.fromJson(Map<String, dynamic> json) {
    return KostRoom(
      id: json['id'],
      roomNumber: json['room_number'],
      type: json['type'],
      price: (json['price'] as num).toDouble(),
      status: json['status'],
      description: json['description'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_number': roomNumber,
      'type': type,
      'price': price,
      'status': status,
      'description': description,
      'image_url': imageUrl,
    };
  }
}

// Tenant Model
class Tenant {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? ktpNumber;
  final String roomId;
  final DateTime checkInDate;
  final DateTime? checkOutDate;
  final String status; // active, inactive
  final String? photoUrl;

  Tenant({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.ktpNumber,
    required this.roomId,
    required this.checkInDate,
    this.checkOutDate,
    required this.status,
    this.photoUrl,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      ktpNumber: json['ktp_number'],
      roomId: json['room_id'],
      checkInDate: DateTime.parse(json['check_in_date']),
      checkOutDate: json['check_out_date'] != null 
          ? DateTime.parse(json['check_out_date']) 
          : null,
      status: json['status'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'ktp_number': ktpNumber,
      'room_id': roomId,
      'check_in_date': checkInDate.toIso8601String(),
      'check_out_date': checkOutDate?.toIso8601String(),
      'status': status,
      'photo_url': photoUrl,
    };
  }
}

// Payment Model
class Payment {
  final String id;
  final String tenantId;
  final String roomId;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status; // pending, paid, overdue
  final String? proofImageUrl;
  final String? notes;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.tenantId,
    required this.roomId,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.proofImageUrl,
    this.notes,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      tenantId: json['tenant_id'],
      roomId: json['room_id'],
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['due_date']),
      paidDate: json['paid_date'] != null 
          ? DateTime.parse(json['paid_date']) 
          : null,
      status: json['status'],
      proofImageUrl: json['proof_image_url'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'room_id': roomId,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'paid_date': paidDate?.toIso8601String(),
      'status': status,
      'proof_image_url': proofImageUrl,
      'notes': notes,
    };
  }
}

// Complaint Model
class Complaint {
  final String id;
  final String tenantId;
  final String roomId;
  final String title;
  final String description;
  final String category; // maintenance, cleanliness, facility, other
  final String status; // pending, in_progress, resolved
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  Complaint({
    required this.id,
    required this.tenantId,
    required this.roomId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.imageUrl,
    required this.createdAt,
    this.resolvedAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      tenantId: json['tenant_id'],
      roomId: json['room_id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      status: json['status'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      resolvedAt: json['resolved_at'] != null 
          ? DateTime.parse(json['resolved_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'room_id': roomId,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'image_url': imageUrl,
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }
}