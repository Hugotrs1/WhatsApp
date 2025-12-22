import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatsapp/api/apiService.dart';

import '../styles/appTheme.dart';
import 'accueil.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  static const String _genericErrorMessage =
      'Une erreur est survenue. Veuillez réessayer.';

  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupFirstNameController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  bool _showLoginPassword = false;
  bool _showSignupPassword = false;
  bool _showSignupConfirmPassword = false;
  bool _rememberMe = false;
  bool _isLoggingIn = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

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
    final media = MediaQuery.of(context);
    final availableHeight = media.size.height - media.viewInsets.bottom;
    final cardHeight = (availableHeight * 0.62).clamp(360.0, 560.0).toDouble();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.brandLight,
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              20,
              24,
              20,
              28 + media.viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildAuthCard(context, cardHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.headlineSmall?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppTheme.brandDark,
          letterSpacing: 0.3,
        ) ??
        const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppTheme.brandDark,
          letterSpacing: 0.3,
        );
    final subtitleStyle = textTheme.bodyMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.muted,
        ) ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.muted,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.brandMid,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              'WhatsApp',
              style: titleStyle,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Discute vite, clair, et sans effort.',
          style: subtitleStyle,
        ),
      ],
    );
  }
  Widget _buildAuthCard(BuildContext context, double cardHeight) {
    final textTheme = Theme.of(context).textTheme;
    final tabLabelStyle = textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ) ??
        const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          TabBar(
            labelColor: AppTheme.brandDark,
            unselectedLabelColor: AppTheme.muted,
            indicatorColor: AppTheme.accent,
            labelStyle: tabLabelStyle,
            tabs: const [
              Tab(text: 'Connexion'),
              Tab(text: 'Inscription'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: cardHeight,
            child: TabBarView(
              children: [
                _buildLoginForm(context),
                _buildSignupForm(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.brandDark,
        ) ??
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.brandDark,
        );
    final subtitleStyle = textTheme.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.muted,
        ) ??
        const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.muted,
        );
    final checkboxStyle = textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.brandDark,
          fontSize: 13,
        ) ??
        const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.brandDark,
          fontSize: 13,
        );
    return Form(
      key: _loginFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Heureux de te revoir',
              style: titleStyle,
            ),
            const SizedBox(height: 6),
            Text(
              'Entre tes identifiants pour continuer.',
              style: subtitleStyle,
            ),
            const SizedBox(height: 18),
            _buildFormField(
              context,
              controller: _loginPhoneController,
              label: 'Telephone',
              keyboardType: TextInputType.phone,
              inputFormatters: [LengthLimitingTextInputFormatter(10)],
              icon: Icons.phone_iphone_outlined,
              validator: _phoneValidator,
            ),
            const SizedBox(height: 14),
            _buildFormField(
              context,
              controller: _loginPasswordController,
              label: 'Mot de passe',
              obscureText: !_showLoginPassword,
              isPassword: true,
              icon: Icons.lock_outline,
              suffixIcon: _buildPasswordToggle(
                isVisible: _showLoginPassword,
                onPressed: () => setState(() => _showLoginPassword = !_showLoginPassword),
              ),
              validator: (value) => _requiredValidator(value, 'Mot de passe'),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _rememberMe,
              onChanged: (value) async {
                final shouldRemember = value ?? false;
                setState(() => _rememberMe = shouldRemember);
                if (!shouldRemember) {
                  await ApiService().clearRememberedCredentials();
                }
              },
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppTheme.accent,
              title: Text(
                'Se souvenir de moi',
                style: checkboxStyle,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _handleAuthSuccess,
                style: TextButton.styleFrom(foregroundColor: AppTheme.tabMuted),
                child: const Text('Skip'),
              ),
            ),
            const SizedBox(height: 16),
            _buildPrimaryButton(
              context,
              label: 'Se connecter',
              onPressed: _handleLogin,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.brandDark,
        ) ??
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.brandDark,
        );
    final subtitleStyle = textTheme.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.muted,
        ) ??
        const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.muted,
        );
    return Form(
      key: _signupFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Creer un compte',
              style: titleStyle,
            ),
            const SizedBox(height: 6),
            Text(
              'Rejoins tes amis et tes groupes en quelques secondes.',
              style: subtitleStyle,
            ),
            const SizedBox(height: 18),
            _buildFormField(
              context,
              controller: _signupNameController,
              label: 'Nom',
              textCapitalization: TextCapitalization.words,
              icon: Icons.badge_outlined,
              validator: (value) => _requiredValidator(value, 'Nom'),
            ),
            const SizedBox(height: 14),
            _buildFormField(
              context,
              controller: _signupFirstNameController,
              label: 'Prenom',
              textCapitalization: TextCapitalization.words,
              icon: Icons.person_outline,
              validator: (value) => _requiredValidator(value, 'Prenom'),
            ),
            const SizedBox(height: 14),
            _buildFormField(
              context,
              controller: _signupPhoneController,
              label: 'Telephone',
              keyboardType: TextInputType.phone,
              inputFormatters: [LengthLimitingTextInputFormatter(10)],
              icon: Icons.phone_iphone_outlined,
              validator: _phoneValidator,
            ),
            const SizedBox(height: 14),
            _buildFormField(
              context,
              controller: _signupPasswordController,
              label: 'Mot de passe',
              obscureText: !_showSignupPassword,
              isPassword: true,
              icon: Icons.lock_outline,
              suffixIcon: _buildPasswordToggle(
                isVisible: _showSignupPassword,
                onPressed: () => setState(() => _showSignupPassword = !_showSignupPassword),
              ),
              validator: (value) => _requiredValidator(value, 'Mot de passe'),
            ),
            const SizedBox(height: 14),
            _buildFormField(
              context,
              controller: _signupConfirmController,
              label: 'Confirmer le mot de passe',
              obscureText: !_showSignupConfirmPassword,
              isPassword: true,
              icon: Icons.check_circle_outline,
              suffixIcon: _buildPasswordToggle(
                isVisible: _showSignupConfirmPassword,
                onPressed: () => setState(
                  () => _showSignupConfirmPassword = !_showSignupConfirmPassword,
                ),
              ),
              validator: _confirmPasswordValidator,
            ),
            const SizedBox(height: 16),
            _buildPrimaryButton(
              context,
              label: 'Créer un compte',
              onPressed: _handleRegister,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool isPassword = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    IconData? icon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final fieldStyle = textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.brandDark,
        ) ??
        const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.brandDark,
        );
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enableSuggestions: !isPassword,
      autocorrect: !isPassword,
      textCapitalization: textCapitalization,
      validator: validator,
      inputFormatters: inputFormatters,
      style: fieldStyle,
      decoration: _inputDecoration(
        label: label,
        icon: icon,
        suffixIcon: suffixIcon,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildPasswordToggle({
    required bool isVisible,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      tooltip: isVisible ? 'Masquer' : 'Afficher',
      icon: Icon(
        isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final buttonTextStyle = textTheme.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ) ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        );
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonBorderRadius),
          textStyle: buttonTextStyle,
        ),
        child: Text(label),
      ),
    );
  }

  String? _requiredValidator(String? value, String fieldLabel) {
    if (value == null || value.trim().isEmpty) {
      return 'Merci de renseigner $fieldLabel.';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Merci de renseigner Telephone.';
    }
    final normalized = trimmed.replaceAll(RegExp(r'[\s()-]'), '');
    if (!RegExp(r'^\+?\d+$').hasMatch(normalized)) {
      return 'Numero invalide.';
    }
    if (normalized.replaceFirst('+', '').length < 6) {
      return 'Numero trop court.';
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

  Future<void> _loadRememberedCredentials() async {
    final saved = await ApiService().getRememberedCredentials();
    if (!mounted || saved == null) return;
    _loginPhoneController.text = saved['phone'] ?? '';
    _loginPasswordController.text = saved['password'] ?? '';
    setState(() => _rememberMe = true);
  }

  Future<void> _saveRememberedCredentials() async {
    final phone = _loginPhoneController.text.trim();
    final password = _loginPasswordController.text;
    if (phone.isEmpty || password.isEmpty) return;
    await ApiService().saveRememberedCredentials(
      phone: phone,
      password: password,
    );
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
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) {
        log('Erreur de connexion: $message');
        return message;
      }
      final details = error['details'];
      if (details is String && details.trim().isNotEmpty) {
        log('Erreur de connexion: $details');
        return details;
      }
      if (details is Map && details['message'] is String) {
        final detailsMessage = details['message'] as String;
        if (detailsMessage.trim().isNotEmpty) {
          log('Erreur de connexion: $detailsMessage');
          return detailsMessage;
        }
      }
      log('Erreur de connexion: $error');
      return _genericErrorMessage;
    }
    if (error is String && error.trim().isNotEmpty) {
      log('Erreur de connexion: $error');
      return error;
    }
    if (error != null) {
      log('Erreur de connexion: $error');
    } else {
      log('Erreur de connexion sans details: $response');
    }
    return _genericErrorMessage;
  }

  Future<void> _showErrorDialog(String message, {String title = 'Connexion impossible'}) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleLogin() async {
    if (_isLoggingIn) return;
    final isValid = _loginFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      _showSnackBar('Merci de remplir les champs requis.');
      return;
    }
    setState(() => _isLoggingIn = true);
    try {
      final response = await ApiService().login(
        password: _loginPasswordController.text.trim(),
        phone: _loginPhoneController.text.trim(),
      );
      final token = _readToken(response);
      if (token != null) {
        await ApiService().saveToken(token);
      }
      log('Response: $response');
      if (!mounted) return;
      if (response['ok'] == true && token != null) {
        if (_rememberMe) {
          await _saveRememberedCredentials();
        } else {
          await ApiService().clearRememberedCredentials();
        }
        await ApiService().saveConnectionStatus(estConnecte: true);
        _handleAuthSuccess();
      } else if (response['ok'] == true && token == null) {
        _showErrorDialog('Connexion impossible. Token manquant.');
      } else {
        final message = _readErrorMessage(response);
        _showErrorDialog(message);
      }
    } catch (error, stackTrace) {
      log(
        'Erreur lors de la connexion',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      _showErrorDialog(_genericErrorMessage);
    } finally {
      if (!mounted) return;
      setState(() => _isLoggingIn = false);
    }
  }

  Future<void> _handleRegister() async {
    if (_isRegistering) return;
    final isValid = _signupFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      _showSnackBar('Merci de remplir les champs requis.');
      return;
    }
    setState(() => _isRegistering = true);
    try {
      final response = await ApiService().register(
        lastName: _signupNameController.text.trim(),
        firstName: _signupFirstNameController.text.trim(),
        phone: _signupPhoneController.text.trim(),
        password: _signupPasswordController.text.trim(),
      );
      log('Response: $response');
      if (!mounted) return;
      if (response['ok'] == true) {
        _showSnackBar('Compte cree. Connecte-toi.');
      } else {
        _showErrorDialog(
          _readErrorMessage(response),
          title: 'Inscription impossible',
        );
      }
    } catch (error, stackTrace) {
      log(
        'Erreur lors de l inscription',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      _showErrorDialog(
        _genericErrorMessage,
        title: 'Inscription impossible',
      );
    } finally {
      if (!mounted) return;
      setState(() => _isRegistering = false);
    }
  }

}
