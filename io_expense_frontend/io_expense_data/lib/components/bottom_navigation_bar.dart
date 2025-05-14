import 'package:flutter/material.dart';

class BottomNavigationBarComponent extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigationBarComponent({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: onTap,
      indicatorColor: Colors.amber,
      selectedIndex: currentIndex,
      destinations: const <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: 'Budget',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          label: ' ',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          label: 'Analytics',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
