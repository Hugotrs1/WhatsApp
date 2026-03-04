// ignore_for_file: file_names
import 'dart:async';

import 'package:flutter/material.dart';

import '../api/apiService.dart';
import '../models/userSummary.dart';
import '../styles/styles.dart';
import '../utils/utils.dart';
import 'detailsUserScreen.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  static const Duration _debounceDelay = Duration(milliseconds: 350);
  static const String _genericErrorMessage = 'Something went wrong. Please try again.';

  late final ApiService _apiService;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  String? _error;
  int _searchToken = 0;
  bool _isShowingAll = false;
  bool _suppressSearch = false;
  List<UserSummary> _results = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: WhatsAppStyles.pagePadding,
      children: [
        Text(
          'Find a friend',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Type a phone number to find your friend and send an invitation.',
          style: WhatsAppStyles.mutedBodyStyle(context),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _searchController,
          keyboardType: TextInputType.phone,
          decoration: WhatsAppStyles.searchFieldDecoration(
            hintText: 'Search by number',
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : _loadAllUsers,
            child: const Text('Show everyone'),
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoading) const LinearProgressIndicator(),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w700),
            ),
          ),
        const SizedBox(height: 12),
        ..._buildResultsList(),
      ],
    );
  }

  List<Widget> _buildResultsList() {
    if (_results.isEmpty) {
      final showHint = _searchController.text.trim().length < 2 && !_isShowingAll;
      final message = _isShowingAll
          ? 'No users.'
          : (showHint ? 'Start typing a number.' : 'No users found.');
      return [
        const SizedBox(height: 40),
        Center(
          child: Text(
            message,
            style: WhatsAppStyles.mutedBodyStyle(context),
          ),
        ),
      ];
    }
    return _results
        .map(
          (item) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: WhatsAppStyles.primaryColor.withOpacity(0.12),
                child: Text(
                  item.initials,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              title: Text(item.displayName),
              subtitle: Text(item.displayPhone),
              trailing: _buildStatusChip(item),
              onTap: () => _openUserDetail(item.id),
            ),
          ),
        )
        .toList();
  }

  Widget _buildStatusChip(UserSummary item) {
    final isFriend = item.isFriend;
    if (isFriend) {
      return Chip(
        label: const Text('Friend'),
        backgroundColor: Colors.green.shade50,
        labelStyle: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w700),
      );
    }
    return const Icon(Icons.chevron_right);
  }

  void _onSearchChanged() {
    if (_suppressSearch) {
      _suppressSearch = false;
      return;
    }
    _isShowingAll = false;
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, _performSearch);
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    final digits = normalizeDigits(query);
    if (digits.length < 2) {
      setState(() {
        _results = [];
        _error = null;
        _isLoading = false;
      });
      return;
    }

    final token = ++_searchToken;
    _isShowingAll = false;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.searchUsersByPhonePrefix(
        phonePrefix: digits,
        limit: 15,
      );
      if (!mounted || token != _searchToken) return;
      if (response['ok'] == true) {
        final data = response['data'];
        final list = parseList<UserSummary>(data, (map) => UserSummary.fromMap(map));
        setState(() {
          _results = list;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = _apiService.readErrorMessage(response);
        });
      }
    } catch (_) {
      if (!mounted || token != _searchToken) return;
      setState(() {
        _isLoading = false;
        _error = _genericErrorMessage;
      });
    }
  }

  Future<void> _loadAllUsers() async {
    final token = ++_searchToken;
    _suppressSearch = true;
    _searchController.clear();
    setState(() {
      _isLoading = true;
      _error = null;
      _isShowingAll = true;
    });

    try {
      final response = await _apiService.listAllUsers(limit: 100);
      if (!mounted || token != _searchToken) return;
      if (response['ok'] == true) {
        final data = response['data'];
        final list = parseList<UserSummary>(data, (map) => UserSummary.fromMap(map));
        setState(() {
          _results = list;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = _apiService.readErrorMessage(response);
        });
      }
    } catch (_) {
      if (!mounted || token != _searchToken) return;
      setState(() {
        _isLoading = false;
        _error = _genericErrorMessage;
      });
    }
  }

  Future<void> _openUserDetail(String userId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UserDetailPage(userId: userId)),
    );
    if (_isShowingAll) {
      _loadAllUsers();
    } else {
      _performSearch();
    }
  }
}
