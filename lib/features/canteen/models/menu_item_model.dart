import 'dart:typed_data';

class MenuTopping {
  final String name;
  final double price;

  const MenuTopping({
    required this.name,
    required this.price,
  });
}

class MenuItemModel {
  final String id;
  final String canteenId;
  final String canteenName;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final Uint8List? imageBytes;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final int stock;
  final bool isBestSeller;
  final int prepTimeMinutes;
  final List<String> availableSpicyLevels;
  final List<MenuTopping> availableToppings;

  const MenuItemModel({
    required this.id,
    required this.canteenId,
    required this.canteenName,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.imageBytes,
    required this.category,
    this.rating = 4.8,
    this.reviewCount = 120,
    this.isAvailable = true,
    this.stock = 20,
    this.isBestSeller = false,
    this.prepTimeMinutes = 10,
    this.availableSpicyLevels = const [
      'Level 0 (Tidak Pedas)',
      'Level 1 (Sedang)',
      'Level 2 (Pedas)',
      'Level 3 (Extra Pedas)',
    ],
    this.availableToppings = const [
      MenuTopping(name: 'Telur Mata Sapi', price: 3000),
      MenuTopping(name: 'Kerupuk Kaleng', price: 1000),
      MenuTopping(name: 'Ekstra Sambal', price: 1000),
      MenuTopping(name: 'Ekstra Nasi', price: 3000),
    ],
  });

  bool get isOutOfStock => !isAvailable || stock <= 0;

  bool get hasImage =>
      (imageBytes != null && imageBytes!.isNotEmpty) ||
      imageUrl.trim().isNotEmpty;

  MenuItemModel copyWith({
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    Uint8List? imageBytes,
    bool clearImageBytes = false,
    String? category,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    int? stock,
    bool? isBestSeller,
    int? prepTimeMinutes,
    List<String>? availableSpicyLevels,
    List<MenuTopping>? availableToppings,
  }) {
    return MenuItemModel(
      id: id,
      canteenId: canteenId,
      canteenName: canteenName,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: clearImageBytes ? null : (imageBytes ?? this.imageBytes),
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      stock: stock ?? this.stock,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      availableSpicyLevels: availableSpicyLevels ?? this.availableSpicyLevels,
      availableToppings: availableToppings ?? this.availableToppings,
    );
  }
}
