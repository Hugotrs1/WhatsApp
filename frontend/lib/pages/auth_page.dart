import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:whatsapp/api/api_service.dart';

import '../styles/whatsapp_style.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupFirstNameController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmController = TextEditingController();
  final _signupFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupFirstNameController.dispose();
    _signupPhoneController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: WhatsAppStyles.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  'WhatsApp',
                  textAlign: TextAlign.center,
                  style: WhatsAppStyles.brandTitleStyle(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connecte-toi pour discuter en toute simplicité.',
                  textAlign: TextAlign.center,
                  style: WhatsAppStyles.mutedBodyStyle(context),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: WhatsAppStyles.cardDecoration,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      TabBar(
                        labelColor: WhatsAppStyles.primaryColor,
                        unselectedLabelColor: Colors.grey.shade600,
                        indicatorColor: WhatsAppStyles.primaryColor,
                        tabs: const [
                          Tab(text: 'Connexion'),
                          Tab(text: 'Inscription'),
                        ],
                      ),
                      SizedBox(
                        height: 420,
                        child: TabBarView(
                          children: [
                            _buildLoginForm(context),
                            _buildSignupForm(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Padding(
      padding: WhatsAppStyles.authFormPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildField(
            controller: _loginPhoneController,
            label: 'Téléphone',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildField(
            controller: _loginPasswordController,
            label: 'Mot de passe',
            obscureText: true,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              try {
                final response = await ApiService().login(
                  password: _loginPasswordController.text.trim(),
                  phone: _loginPhoneController.text.trim(),
                );
                final token = _readToken(response);
                if (token != null) {
                  await ApiService().saveToken(token);
                }
                log("Response: $response");
                if (!mounted) return;
                if (response['ok'] == true && token != null) {
                  _handleAuthSuccess();
                } else {
                  final message = _readErrorMessage(response);
                  log('Connexion impossible: $message');
                  _showErrorDialog(message);
                }
              } catch (error) {
                if (!mounted) return;
                _showErrorDialog(error.toString());
              }
            },
            style: WhatsAppStyles.primaryButtonStyle,
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm(BuildContext context) {
    return Padding(
      padding: WhatsAppStyles.authFormCompactPadding,
      child: Form(
        key: _signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFormField(
              controller: _signupNameController,
              label: 'Nom',
              textCapitalization: TextCapitalization.words,
              validator: (value) => _requiredValidator(value, 'Nom'),
            ),
            const SizedBox(height: 16),
            _buildFormField(
              controller: _signupFirstNameController,
              label: 'Prenom',
              textCapitalization: TextCapitalization.words,
              validator: (value) => _requiredValidator(value, 'Prenom'),
            ),
            const SizedBox(height: 16),
            _buildFormField(
              controller: _signupPhoneController,
              label: 'Telephone',
              keyboardType: TextInputType.phone,
              validator: (value) => _requiredValidator(value, 'Telephone'),
            ),
            const SizedBox(height: 16),
            _buildFormField(
              controller: _signupPasswordController,
              label: 'Mot de passe',
              obscureText: true,
              validator: (value) => _requiredValidator(value, 'Mot de passe'),
            ),
            const SizedBox(height: 16),
            _buildFormField(
              controller: _signupConfirmController,
              label: 'Confirmer le mot de passe',
              obscureText: true,
              validator: _confirmPasswordValidator,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final isValid = _signupFormKey.currentState?.validate() ?? false;
                if (!isValid) return;
                final response = await ApiService().register(
                  lastName: _signupNameController.text.trim(),
                  firstName: _signupFirstNameController.text.trim(),
                  phone: _signupPhoneController.text.trim(),
                  password: _signupPasswordController.text.trim(),
                );
                log("Response: $response");
              },
              style: WhatsAppStyles.primaryButtonStyle,
              child: const Text('Creer un compte'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      decoration: WhatsAppStyles.formFieldDecoration(label: label),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: WhatsAppStyles.formFieldDecoration(label: label),
    );
  }

  String? _requiredValidator(String? value, String fieldLabel) {
    if (value == null || value.trim().isEmpty) {
      return 'Merci de renseigner $fieldLabel.';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Merci de confirmer le mot de passe.';
    }
    if (value.trim() != _signupPasswordController.text.trim()) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }

  void _handleAuthSuccess() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  String? _readToken(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map && data['token'] is String) {
      return data['token'] as String;
    }
    return null;
  }

  String _readErrorMessage(Map<String, dynamic> response) {
    final error = response['error'];
    if (error is Map) {
      final details = error['details'];
      if (details is Map && details['error'] is String) {
        log("Error message: ${error['details']}");
        return details['error'] as String;
      }
      if (error['message'] is String) {
        log("Error message: ${error['message']}");
        return error['message'] as String;
      }
    }
    log(  "Error message: unknown error $response");
    return 'Connexion impossible.';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connexion impossible'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
