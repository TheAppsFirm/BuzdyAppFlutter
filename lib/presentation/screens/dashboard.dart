import 'package:buzdy/presentation/screens/dashboard/crypto/CryptoScreen.dart';
import 'package:buzdy/presentation/screens/dashboard/feed/feed.dart';
import 'package:buzdy/presentation/screens/dashboard/banks/bank.dart';
import 'package:buzdy/presentation/screens/dashboard/products/products.dart';
import 'package:buzdy/presentation/screens/dashboard/home/home_dashboard.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/core/colors.dart';
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            type: BottomNavigationBarType.fixed,
            elevation: 8.0,
            showUnselectedLabels: true,
            unselectedLabelStyle: textStyleExoBold(fontSize: 12),
            selectedLabelStyle: textStyleExoBold(fontSize: 12),
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).colorScheme.onPrimary,
            unselectedItemColor:
                Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
            onTap: _onItemTapped,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: iconShow(image: 'images/home.png'),
                label: 'Home'.tr,
                activeIcon: activeIcon(image: 'images/home.png'),
              ),
              BottomNavigationBarItem(
                icon: iconShow(image: 'images/currency-exchange.png'),
                label: 'Crypto'.tr,
                activeIcon: activeIcon(image: 'images/currency-exchange.png'),
              ),
              BottomNavigationBarItem(
                icon: iconShow(image: "images/home.png"),
                label: 'Business'.tr,
                activeIcon: activeIcon(image: 'images/home.png'),
              ),
              BottomNavigationBarItem(
                icon: iconShow(image: 'images/cubes.png'),
                label: 'Products'.tr,
                activeIcon: activeIcon(image: 'images/cubes.png'),
              ),
              BottomNavigationBarItem(
                icon: iconShow(image: 'images/youtube.png'),
                label: 'Feed'.tr,
                activeIcon: activeIcon(image: 'images/youtube.png'),
              ),
            ],
          ),
        );
      },
    );
  }

  Image iconShow({required String image}) {
    return Image.asset(image, height: 23, width: 23);
  }

  Widget activeIcon({required String image}) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Image.asset(image, height: 23, width: 23),
    );
  }
}