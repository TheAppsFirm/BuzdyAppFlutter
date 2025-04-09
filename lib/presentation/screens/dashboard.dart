import 'package:buzdy/presentation/screens/dashboard/crypto/CryptoScreen.dart';
import 'package:buzdy/presentation/screens/dashboard/feed/feed.dart';
import 'package:buzdy/presentation/screens/dashboard/banks/bank.dart';
import 'package:buzdy/presentation/screens/dashboard/profile.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';

class DashBorad extends StatefulWidget {
  final int index;
  const DashBorad({Key? key, required this.index}) : super(key: key);
  
  @override
  _DashBoradState createState() => _DashBoradState();
}

class _DashBoradState extends State<DashBorad> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    CryptoScreen(),
    HomeScreen(),
    FeedScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewmodel, child) {
        return Scaffold(
          backgroundColor: whiteColor,
          // Preserve the state for each page using IndexedStack.
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: appButtonColor,
            type: BottomNavigationBarType.fixed,
            elevation: 8.0,
            showUnselectedLabels: true,
            unselectedLabelStyle: textStyleExoBold(fontSize: 12),
            selectedLabelStyle: textStyleExoBold(fontSize: 12),
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.black,
            unselectedItemColor: const Color(0xff51443A),
            onTap: _onItemTapped,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: iconShow(image: 'images/currency-exchange.png'),
                label: 'Crypto'.tr,
                activeIcon: activeIcon(image: 'images/currency-exchange.png'),
              ),
              BottomNavigationBarItem(
                icon: iconShow(image: "images/home.png"),
                label: 'Banks'.tr,
                activeIcon: activeIcon(image: 'images/home.png'),
              ),
              BottomNavigationBarItem(
                icon: iconShow(image: 'images/youtube.png'),
                label: 'Feed'.tr,
                activeIcon: activeIcon(image: 'images/youtube.png'),
              ),
              BottomNavigationBarItem(
                icon: iconShow(image: 'images/user.png'),
                label: 'Profile'.tr,
                activeIcon: activeIcon(image: 'images/user.png'),
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
      // Removed the border radius for a simple tab style.
      child: Image.asset(image, height: 23, width: 23),
    );
  }
}
