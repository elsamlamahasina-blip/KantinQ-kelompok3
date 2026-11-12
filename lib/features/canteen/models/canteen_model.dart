import 'menu_item_model.dart';

class CanteenModel {
  final String id;
  final String name;
  final String description;
  final String bannerUrl;
  final String avatarUrl;
  final String location;
  final String phone;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final String openHours;
  final int activeQueueCount;
  final List<String> categories;
  final List<MenuItemModel> menus;

  const CanteenModel({
    required this.id,
    required this.name,
    required this.description,
    required this.bannerUrl,
    required this.avatarUrl,
    required this.location,
    this.phone = '081298765432',
    required this.rating,
    required this.reviewCount,
    this.isOpen = true,
    this.openHours = '07:30 - 16:30 WIB',
    this.activeQueueCount = 3,
    required this.categories,
    this.menus = const [],
  });

  CanteenModel copyWith({
    String? name,
    String? description,
    String? bannerUrl,
    String? avatarUrl,
    String? location,
    String? phone,
    double? rating,
    int? reviewCount,
    bool? isOpen,
    String? openHours,
    int? activeQueueCount,
    List<String>? categories,
    List<MenuItemModel>? menus,
  }) {
    return CanteenModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isOpen: isOpen ?? this.isOpen,
      openHours: openHours ?? this.openHours,
      activeQueueCount: activeQueueCount ?? this.activeQueueCount,
      categories: categories ?? this.categories,
      menus: menus ?? this.menus,
    );
  }
}

