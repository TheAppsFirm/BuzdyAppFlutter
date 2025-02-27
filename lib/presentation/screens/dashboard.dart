import 'package:buzdy/presentation/screens/dashboard/deals/deals.dart';
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
  int index;
  DashBorad({super.key, required this.index});
  @override
  _DashBoradState createState() => _DashBoradState();
}

class _DashBoradState extends State<DashBorad> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _selectedIndex = widget.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(builder: (context, viewmodel, child) {
      return Scaffold(
        backgroundColor: whiteColor,
        body: _getPage(_selectedIndex),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: appButtonColor,
          ),
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              child: BottomNavigationBar(
                  backgroundColor: appButtonColor,
                  type: BottomNavigationBarType
                      .fixed, // Ensure consistent spacing
                  elevation: 0.0,
                  showUnselectedLabels: true,
                  unselectedLabelStyle: textStyleExoBold(fontSize: 12),
                  selectedLabelStyle: textStyleExoBold(fontSize: 12),
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: iconShow(image: 'images/currency-exchange.png'),
                        label: 'Crypto'.tr,
                        activeIcon:
                            activeIcon(image: 'images/currency-exchange.png')),
                    BottomNavigationBarItem(
                        icon: iconShow(image: "images/home.png"),
                        label: 'Banks'.tr,
                        activeIcon: activeIcon(image: 'images/home.png')),
                    BottomNavigationBarItem(
                        icon: iconShow(image: 'images/youtube.png'),
                        label: 'Feed'.tr,
                        activeIcon: activeIcon(image: 'images/youtube.png')),
                    BottomNavigationBarItem(
                        icon: iconShow(image: 'images/user.png'),
                        label: '⁠Profile'.tr,
                        activeIcon: activeIcon(image: 'images/user.png')),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.black,
                  unselectedItemColor: const Color(0xff51443A),
                  onTap: _onItemTapped),
            ),
          ),
        ),
      );
    });
  }

  Image iconShow({image}) {
    return Image.asset(image ?? 'images/home.png', height: 23, width: 23);
  }

  Container activeIcon({image}) {
    return Container(
      width: 50,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xffCCE5FF),
          borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Image.asset(image, height: 23, width: 23),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return DealerScreen();
      case 1:
        return HomeScreen();
      case 2:
        return FeedScreen();
      case 3:
        return ProfileScreen();
      default:
        return Container();
    }
  }
}
