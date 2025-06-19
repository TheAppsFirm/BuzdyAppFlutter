import 'package:buzdy/presentation/screens/dashboard/crypto/CryptoScreen.dart';
import 'package:buzdy/presentation/screens/dashboard/feed/feed.dart';
import 'package:buzdy/presentation/screens/dashboard/banks/bank.dart';
import 'package:buzdy/presentation/screens/dashboard/products/products.dart';
import 'package:buzdy/presentation/screens/dashboard/home/home_dashboard.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/core/constants.dart';
import 'package:buzdy/core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';

class DashBoard extends StatefulWidget {
  final int index;
  const DashBoard({Key? key, required this.index}) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int _selectedIndex = 0;
  late PageController _pageController;

  // Main pages for the bottom navigation bar.
  final List<Widget> _pages = const [
    HomeDashboardScreen(),
    CryptoScreen(),
    HomeScreen(),
    ProductsScreen(),
    FeedScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewmodel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            // Use a constant white background to keep tabs clean
            backgroundColor: kWhiteColor,
            type: BottomNavigationBarType.fixed,
            elevation: 8.0,
            showUnselectedLabels: true,
            unselectedLabelStyle:
                textStyleExoBold(fontSize: 12, color: kIconGrey),
            selectedLabelStyle:
                textStyleExoBold(fontSize: 12, color: kMainBlackColor),
            currentIndex: _selectedIndex,
            selectedItemColor: kMainBlackColor,
            unselectedItemColor: kIconGrey,
            onTap: _onItemTapped,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: 'Home'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.currency_bitcoin_outlined),
                activeIcon: const Icon(Icons.currency_bitcoin),
                label: 'Crypto'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.business_center_outlined),
                activeIcon: const Icon(Icons.business_center),
                label: 'Business'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_bag_outlined),
                activeIcon: const Icon(Icons.shopping_bag),
                label: 'Products'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.video_library_outlined),
                activeIcon: const Icon(Icons.video_library),
                label: 'Feed'.tr,
              ),
            ],
          ),
        );
      },
    );
  }

}