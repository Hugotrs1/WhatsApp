import 'dart:async';

import 'package:flutter/material.dart';

import '../api/apiService.dart';
import '../styles/styles.dart';
import 'detailsUser.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  static const Duration _debounceDelay = Duration(milliseconds: 350);
  static const String _genericErrorMessage = 'Une erreur est survenue. Veuillez réessayer.';

  late final ApiService _apiService;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  String? _error;
  int _searchToken = 0;
  List<Map<String, dynamic>> _results = [];

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
          'Rechercher un ami',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Tape un numéro de téléphone pour trouver ton ami et lui envoyer une invitation.',
          style: WhatsAppStyles.mutedBodyStyle(context),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _searchController,
          keyboardType: TextInputType.phone,
          decoration: WhatsAppStyles.searchFieldDecoration(
            hintText: 'Rechercher par numéro',
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
      return [
        const SizedBox(height: 40),
        Center(
          child: Text(
            _searchController.text.trim().length < 2
                ? 'Commence à taper un numéro.'
                : 'Aucun utilisateur trouvé.',
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
                  _initials(item),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              title: Text(_displayName(item)),
              subtitle: Text(item['phone_masked']?.toString() ?? ''),
              trailing: _buildStatusChip(item),
              onTap: () => _openUserDetail(item['id'].toString()),
            ),
          ),
        )
        .toList();
  }

  String _displayName(Map<String, dynamic> item) {
    final first = item['first_name']?.toString() ?? '';
    final last = item['last_name']?.toString() ?? '';
    final full = '$first $last'.trim();
    return full.isEmpty ? 'Utilisateur' : full;
  }

  String _initials(Map<String, dynamic> item) {
    final name = _displayName(item);
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Widget _buildStatusChip(Map<String, dynamic> item) {
    final isFriend = item['is_friend'] == true;
    if (isFriend) {
      return Chip(
        label: const Text('Ami'),
        backgroundColor: Colors.green.shade50,
        labelStyle: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w700),
      );
    }
    return const Icon(Icons.chevron_right);
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, _performSearch);
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    final digits = query.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 2) {
      setState(() {
        _results = [];
        _error = null;
        _isLoading = false;
      });
      return;
    }

    final token = ++_searchToken;
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
        final list = <Map<String, dynamic>>[];
        if (data is List) {
          for (final item in data) {
            if (item is Map) {
              list.add(Map<String, dynamic>.from(item));
            }
          }
        }
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
    _performSearch();
  }
}
