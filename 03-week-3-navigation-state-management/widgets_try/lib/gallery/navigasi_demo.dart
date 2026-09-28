import 'package:flutter/material.dart';

class NavigasiDemo extends StatefulWidget {
  const NavigasiDemo({super.key});

  @override
  State<NavigasiDemo> createState() => _NavigasiDemoState();
}

class _NavigasiDemoState extends State<NavigasiDemo> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Navigasi Widgets'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.star), text: 'Favorit'),
              Tab(icon: Icon(Icons.settings), text: 'Setting'),
            ],
          ),
        ),
        drawer: const Drawer(
          child: Center(child: Text('Ini adalah Drawer')),
        ),
        body: Row(
          children: [
            // NavigationRail (only visible if we want it)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: Text('First'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bookmark_border),
                  selectedIcon: Icon(Icons.book),
                  label: Text('Second'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Main Content
            Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text('Tab 1 - Rail Index: $_currentIndex')),
                  const Center(child: Text('Tab 2')),
                  const Center(child: Text('Tab 3')),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Satu'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Dua'),
          ],
        ),
      ),
    );
  }
}
