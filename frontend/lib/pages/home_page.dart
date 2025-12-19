import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'chats_page.dart';
import 'settings_page.dart';
import 'status_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pages = const [
    ChatsPage(),
    StatusPage(),
    SettingsPage(),
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForIndex(_currentIndex)),
        actions: [
          if (_currentIndex != 2) IconButton(onPressed: () {}, icon: const Icon(Icons.photo_camera_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
          
        ],
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade700,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Discussions'),
          BottomNavigationBarItem(icon: Icon(Icons.timelapse_outlined), label: 'Statuts'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Réglages'),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'WhatsApp';
      case 1:
        return 'Statuts';
      case 2:
        return 'Réglages';
      default:
        return 'WhatsApp';
    }
  }

  Widget? _buildFab() {
    IconData? icon;
    switch (_currentIndex) {
      case 0:
        icon = Icons.message;
        break;
      case 1:
        icon = Icons.photo_camera_outlined;
        break;
      default:
        icon = null;
    }
    if (icon == null) return null;
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      onPressed: () {},
      child: Icon(icon, color: Colors.white),
    );
  }
}
