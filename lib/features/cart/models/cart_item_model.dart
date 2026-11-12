import '../../canteen/models/menu_item_model.dart';

class CartItemModel {
  final String id;
  final MenuItemModel menuItem;
  int quantity;
  final String? selectedSpicyLevel;
  final List<MenuTopping> selectedToppings;
  final String? specialNotes;

  CartItemModel({
    required this.id,
    required this.menuItem,
    this.quantity = 1,
    this.selectedSpicyLevel,
    this.selectedToppings = const [],
    this.specialNotes,
  });

  double get unitPrice {
    double total = menuItem.price;
    for (final topping in selectedToppings) {
      total += topping.price;
    }
    return total;
  }

  double get totalPrice => unitPrice * quantity;

  CartItemModel copyWith({
    int? quantity,
    String? selectedSpicyLevel,
    List<MenuTopping>? selectedToppings,
    String? specialNotes,
  }) {
    return CartItemModel(
      id: id,
      menuItem: menuItem,
      quantity: quantity ?? this.quantity,
      selectedSpicyLevel: selectedSpicyLevel ?? this.selectedSpicyLevel,
      selectedToppings: selectedToppings ?? this.selectedToppings,
      specialNotes: specialNotes ?? this.specialNotes,
    );
  }
}
