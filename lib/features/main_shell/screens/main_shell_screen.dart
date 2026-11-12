import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../auth/screens/login_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../merchant/screens/merchant_dashboard_screen.dart';
import '../../order/screens/orders_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const OrdersScreen(),
      CartScreen(
        onExplorePressed: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = AppState.instance.authController;
    final orderCtrl = AppState.instance.orderController;
    final cartCtrl = AppState.instance.cartController;

    return AnimatedBuilder(
      animation: Listenable.merge([authCtrl, orderCtrl, cartCtrl]),
      builder: (context, _) {
        // If logged out, render LoginScreen
        if (!authCtrl.isLoggedIn) {
          return const LoginScreen();
        }

        // If user is Seller / Merchant, render Merchant Dashboard
        if (authCtrl.currentUser?.isSeller == true) {
          return const MerchantDashboardScreen();
        }

        final activeOrderCount = orderCtrl.activeOrders.length;
        final cartCount = cartCtrl.totalQuantity;

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex.clamp(0, _screens.length - 1),
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.outline, width: 1)),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex.clamp(0, _screens.length - 1),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.storefront_outlined),
                  activeIcon: Icon(Icons.storefront_rounded),
                  label: AppStrings.navHome,
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: activeOrderCount > 0,
                    label: Text('$activeOrderCount'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.receipt_long_outlined),
                  ),
                  activeIcon: Badge(
                    isLabelVisible: activeOrderCount > 0,
                    label: Text('$activeOrderCount'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.receipt_long_rounded),
                  ),
                  label: AppStrings.navOrders,
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  activeIcon: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.shopping_bag_rounded),
                  ),
                  label: AppStrings.navCart,
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: AppStrings.navProfile,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
