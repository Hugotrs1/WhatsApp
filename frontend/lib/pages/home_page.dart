import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../styles/whatsapp_style.dart';
import 'add_contact_page.dart';
import 'chats_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold();
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final List<Widget> _pages = const [
    ChatsPage(),
    AddContactPage(),
    SettingsPage(),
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForIndex(_currentIndex)),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Deconnexion',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: WhatsAppStyles.primaryColor,
        unselectedItemColor: WhatsAppStyles.mutedTextColor,
        showUnselectedLabels: true,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          _buildAddItem(),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Param\u00E8tres',
          ),
        ],
      ),
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Messages';
      case 1:
        return 'Ajout de contact';
      case 2:
        return 'Param\u00E8tres';
      default:
        return 'Messages';
    }
  }

  BottomNavigationBarItem _buildAddItem() {
    final icon = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: WhatsAppStyles.primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.add, color: Colors.white),
    );

    return BottomNavigationBarItem(
      icon: icon,
      activeIcon: icon,
      label: 'Plus',
    );
  }

  Future<void> _handleLogout() async {
    await ApiService().clearToken();
    await ApiService().clearRememberedCredentials();
    await ApiService().clearConnectionStatus();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }
}
