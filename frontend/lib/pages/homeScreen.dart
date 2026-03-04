import 'dart:async';

import 'package:flutter/material.dart';

import '../api/apiService.dart';
import '../models/friendRequest.dart';
import '../presentation/auth/authController.dart';
import '../styles/styles.dart';
import 'addScreen.dart';
import 'chatsScreen.dart';
import 'settingsScreen.dart';
import 'detailsUserScreen.dart';

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
  late final ApiService _apiService;
  FriendRequest? _incomingRequest;
  int _pendingCount = 0;
  Timer? _incomingRequestsTimer;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadIncomingRequests();
    _incomingRequestsTimer =
        Timer.periodic(const Duration(seconds: 2), (_) => _loadIncomingRequests());
  }

  @override
  void dispose() {
    _incomingRequestsTimer?.cancel();
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitle(_currentIndex),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_incomingRequest != null)
            _IncomingRequestBanner(
              request: _incomingRequest!,
              pendingCount: _pendingCount,
              onAccept: () => _acceptRequest(_incomingRequest!.id),
              onDecline: () => _declineRequest(_incomingRequest!.id),
              onView: () => _viewRequester(_incomingRequest!.requesterId),
            ),
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
            icon: Icon(Icons.account_circle),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  String _appBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Messages';
      case 1:
        return 'Add contact';
      case 2:
        return 'Settings';
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
            color: Colors.black.withValues(alpha: 0.15),
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
      label: 'Add',
    );
  }

  Future<void> _handleLogout() async {
    await AuthScope.of(context).logout();
  }

  Future<void> _loadIncomingRequests() async {
    try {
      final response = await _apiService.listIncomingFriendRequests(status: 'PENDING');
      if (response['ok'] != true) {
        return;
      }
      final data = response['data'];
      if (data is! List) {
        return;
      }
      final parsed = data
          .whereType<Map>()
          .map((item) => FriendRequest.fromMap(Map<String, dynamic>.from(item)))
          .toList();
      if (!mounted) return;
      setState(() {
        _pendingCount = parsed.length;
        _incomingRequest = parsed.isNotEmpty ? parsed.first : null;
      });
    } catch (_) {
      // silence polling errors
    }
  }

  Future<void> _acceptRequest(String? requestId) async {
    if (requestId == null) return;
    final response = await _apiService.acceptFriendRequest(requestId: requestId.toString());
    if (response['ok'] != true && mounted) {
      _showBannerMessage(_apiService.readErrorMessage(response));
    }
    await _loadIncomingRequests();
  }

  Future<void> _declineRequest(String? requestId) async {
    if (requestId == null) return;
    final response = await _apiService.declineFriendRequest(requestId: requestId.toString());
    if (response['ok'] != true && mounted) {
      _showBannerMessage(_apiService.readErrorMessage(response));
    }
    await _loadIncomingRequests();
  }

  Future<void> _viewRequester(String? requesterId) async {
    if (requesterId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UserDetailPage(userId: requesterId.toString())),
    );
    await _loadIncomingRequests();
  }

  void _showBannerMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _IncomingRequestBanner extends StatelessWidget {
  const _IncomingRequestBanner({
    required this.request,
    required this.pendingCount,
    required this.onAccept,
    required this.onDecline,
    required this.onView,
  });

  final FriendRequest request;
  final int pendingCount;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final name = request.requester?.displayName ?? 'Someone';
    final extra = pendingCount > 1 ? ' (+${pendingCount - 1})' : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.amber.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_add_alt_1, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$name wants to add you$extra',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(onPressed: onView, child: const Text('View')),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                child: const Text('Accept'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onDecline,
                child: const Text('Decline'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
