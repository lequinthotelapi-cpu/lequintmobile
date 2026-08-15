import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/firestore_converters.dart';

/// Producto del catálogo, usado para agregar cargos a la cuenta de huésped
/// (DECISION-014). `updatedAt`/`updatedBy` son requeridos — igual que en el
/// sistema web.
class Product {
  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.measurementUnit,
    required this.currentStock,
    required this.minStock,
    required this.cost,
    required this.price,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    this.description,
    this.photoUrl,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) =>
      Product.fromMap((doc.data() as Map<String, dynamic>?) ?? {}, doc.id);

  factory Product.fromMap(Map<String, dynamic> map, String id) => Product(
    id: id,
    code: map['code'] as String? ?? '',
    name: map['name'] as String? ?? '',
    category: map['category'] as String? ?? '',
    measurementUnit: map['measurementUnit'] as String? ?? '',
    currentStock: (map['currentStock'] as num?)?.toDouble() ?? 0,
    minStock: (map['minStock'] as num?)?.toDouble() ?? 0,
    cost: (map['cost'] as num?)?.toDouble() ?? 0,
    price: (map['price'] as num?)?.toDouble() ?? 0,
    isActive: map['isActive'] as bool? ?? true,
    createdAt: parseTimestamp(map['createdAt']),
    updatedAt: parseTimestamp(map['updatedAt']),
    createdBy: map['createdBy'] as String? ?? '',
    updatedBy: map['updatedBy'] as String? ?? '',
    description: map['description'] as String?,
    photoUrl: map['photoUrl'] as String?,
  );

  final String id;
  final String code;
  final String name;
  final String? description;
  final String category;
  final String measurementUnit;
  final double currentStock;
  final double minStock;
  final double cost;
  final double price;
  final String? photoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;

  Map<String, dynamic> toFirestore() => {
    'code': code,
    'name': name,
    if (description != null) 'description': description,
    'category': category,
    'measurementUnit': measurementUnit,
    'currentStock': currentStock,
    'minStock': minStock,
    'cost': cost,
    'price': price,
    if (photoUrl != null) 'photoUrl': photoUrl,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'createdBy': createdBy,
    'updatedBy': updatedBy,
  };
}
