import 'package:flutter/material.dart';

class ScrollDemo extends StatelessWidget {
  const ScrollDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('List & Scrolling'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ListView'),
              Tab(text: 'GridView'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ListView
            ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Item ListView ke-$index'),
                  subtitle: const Text('Subjudul list view'),
                );
              },
            ),
            // GridView
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 30,
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.blue[(index % 9 + 1) * 100],
                  child: Center(child: Text('Grid $index')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
