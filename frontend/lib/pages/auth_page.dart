import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:whatsapp/api/api_service.dart';

import '../utils/app_colors.dart';
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  'WhatsApp',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connecte-toi pour discuter en toute simplicité.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      TabBar(
                        labelColor: AppColors.primary,
                        unselectedLabelColor: Colors.grey.shade600,
                        indicatorColor: AppColors.primary,
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
      padding: const EdgeInsets.all(20),
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
              final response = await ApiService().login(
                password: _loginPasswordController.text.trim(),
                phone: _loginPhoneController.text.trim(),
              );
              log("Response: $response");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildField(
            controller: _signupNameController,
            label: 'Nom',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _buildField(
            controller: _signupFirstNameController,
            label: 'Prénom',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _buildField(
            controller: _signupPhoneController,
            label: 'Téléphone',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _buildField(
            controller: _signupPasswordController,
            label: 'Mot de passe',
            obscureText: true,
          ),
          const SizedBox(height: 16),
          _buildField(
            controller: _signupConfirmController,
            label: 'Confirmer le mot de passe',
            obscureText: true,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              final response = await ApiService().register(
                lastName: _signupNameController.text.trim(),
                firstName: _signupFirstNameController.text.trim(),
                phone: _signupPhoneController.text.trim(),
                password: _signupPasswordController.text.trim(),
              );
              log("Response: $response");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Creer un compte'),
          ),
        ],
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
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  void _handleAuthSuccess() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }
}
