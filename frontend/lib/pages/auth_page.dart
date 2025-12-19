import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/api/api_service.dart';

import '../styles/app_theme.dart';
import 'home_page.dart';

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
  bool _estConnecte = true;
  bool _animateIn = false;
  bool _isLoggingIn = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _animateIn = true;
      });
    });
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.brandDark,
                AppTheme.brandMid,
                AppTheme.brandLight,
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -60,
                left: -40,
                child: _buildGlow(200, const Color(0x6629D3B0)),
              ),
              Positioned(
                top: 140,
                right: -70,
                child: _buildGlow(240, const Color(0x664AC5FF)),
              ),
              Positioned(
                bottom: -120,
                left: -90,
                child: _buildGlow(280, const Color(0x6645E6AE)),
              ),
              SafeArea(
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
                      AnimatedSlide(
                        offset: _animateIn ? Offset.zero : const Offset(0, -0.08),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOutCubic,
                        child: AnimatedOpacity(
                          opacity: _animateIn ? 1 : 0,
                          duration: const Duration(milliseconds: 650),
                          child: _buildHeader(),
                        ),
                      ),
                      const SizedBox(height: 28),
                      AnimatedSlide(
                        offset: _animateIn ? Offset.zero : const Offset(0, 0.08),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOutCubic,
                        child: AnimatedOpacity(
                          opacity: _animateIn ? 1 : 0,
                          duration: const Duration(milliseconds: 650),
                          child: _buildAuthCard(context, cardHeight),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.chipBorder),
              ),
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              'WhatsApp',
              style: GoogleFonts.sora(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Discute vite, clair, et sans effort.',
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.82),
          ),
        ),
      ],
    );
  }
  Widget _buildAuthCard(BuildContext context, double cardHeight) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTheme.cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppTheme.cardBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.86),
              borderRadius: AppTheme.cardBorderRadius,
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.tabMuted,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: GoogleFonts.sora(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentDark.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    tabs: const [
                      Tab(text: 'Connexion'),
                      Tab(text: 'Inscription'),
                    ],
                  ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
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
              style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.brandDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Entre tes identifiants pour continuer.',
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 18),
            _buildFormField(
              controller: _loginPhoneController,
              label: 'Telephone',
              keyboardType: TextInputType.phone,
              icon: Icons.phone_iphone_outlined,
              validator: _phoneValidator,
            ),
            const SizedBox(height: 14),
            _buildFormField(
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
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.brandDark,
                  fontSize: 13,
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _estConnecte,
              onChanged: (value) => setState(() => _estConnecte = value),
              dense: true,
              activeColor: AppTheme.accent,
              title: Text(
                'estConnecte',
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.brandDark,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                _estConnecte ? 'En ligne' : 'Hors ligne',
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.muted,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 4,
              children: [
                TextButton(
                  onPressed: _handleAuthSuccess,
                  style: TextButton.styleFrom(foregroundColor: AppTheme.tabMuted),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.sora(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Mot de passe oublie ?',
                    style: GoogleFonts.sora(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPrimaryButton(
              label: 'Se connecter',
              onPressed: _handleLogin,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm(BuildContext context) {
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
              style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.brandDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Rejoins tes amis et tes groupes en quelques secondes.',
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 18),
            _buildFormField(
              controller: _signupNameController,
              label: 'Nom',
              textCapitalization: TextCapitalization.words,
              icon: Icons.badge_outlined,
              validator: (value) => _requiredValidator(value, 'Nom'),
            ),
            const SizedBox(height: 14),
            _buildFormField(
              controller: _signupFirstNameController,
              label: 'Prenom',
              textCapitalization: TextCapitalization.words,
              icon: Icons.person_outline,
              validator: (value) => _requiredValidator(value, 'Prenom'),
            ),
            const SizedBox(height: 14),
            _buildFormField(
              controller: _signupPhoneController,
              label: 'Telephone',
              keyboardType: TextInputType.phone,
              icon: Icons.phone_iphone_outlined,
              validator: _phoneValidator,
            ),
            const SizedBox(height: 14),
            _buildFormField(
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
              label: 'Creer un compte',
              onPressed: _handleRegister,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool isPassword = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enableSuggestions: !isPassword,
      autocorrect: !isPassword,
      textCapitalization: textCapitalization,
      validator: validator,
      style: GoogleFonts.sora(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppTheme.brandDark,
      ),
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

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: AppTheme.buttonBorderRadius,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentDark.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonBorderRadius),
            textStyle: GoogleFonts.sora(fontWeight: FontWeight.w700),
          ),
          child: Text(
            label,
            style: GoogleFonts.sora(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
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
        await ApiService().saveConnectionStatus(estConnecte: _estConnecte);
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

  static Widget _buildGlow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}
