import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/validators.dart';
import '../../styles/appTheme.dart';
import 'authController.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AuthScope.of(context);
    final remembered = controller.rememberedCredentials;
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
                const _AuthHeader(),
                const SizedBox(height: 24),
                _AuthCard(
                  height: cardHeight,
                  loginForm: LoginForm(
                    initialPhone: remembered?.phone ?? '',
                    initialPassword: remembered?.password ?? '',
                    initialRememberMe: remembered?.rememberMe ?? false,
                  ),
                  registerForm: const RegisterForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
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
            Text('WhatsApp', style: titleStyle),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Chat fast, clearly, and effortlessly.',
          style: subtitleStyle,
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.height,
    required this.loginForm,
    required this.registerForm,
  });

  final double height;
  final Widget loginForm;
  final Widget registerForm;

  @override
  Widget build(BuildContext context) {
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
              Tab(text: 'Login'),
              Tab(text: 'Register'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: TabBarView(
              children: [
                loginForm,
                registerForm,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.initialPhone,
    required this.initialPassword,
    required this.initialRememberMe,
  });

  final String initialPhone;
  final String initialPassword;
  final bool initialRememberMe;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  static final List<TextInputFormatter> _phoneFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(18),
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final ValueNotifier<bool> _showPassword;
  late final ValueNotifier<bool> _rememberMe;
  late final ValueNotifier<bool> _isLoading;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
    _passwordController = TextEditingController(text: widget.initialPassword);
    _showPassword = ValueNotifier<bool>(false);
    _rememberMe = ValueNotifier<bool>(widget.initialRememberMe);
    _isLoading = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _showPassword.dispose();
    _rememberMe.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome back', style: titleStyle),
            const SizedBox(height: 6),
            Text('Enter your credentials to continue.', style: subtitleStyle),
            const SizedBox(height: 18),
            _AuthTextField(
              controller: _phoneController,
              label: 'Phone',
              keyboardType: TextInputType.phone,
              inputFormatters: _phoneFormatters,
              icon: Icons.phone_iphone_outlined,
              validator: Validators.phone,
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder<bool>(
              valueListenable: _showPassword,
              builder: (context, isVisible, _) {
                return _AuthTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: !isVisible,
                  isPassword: true,
                  icon: Icons.lock_outline,
                  suffixIcon: _PasswordToggle(
                    isVisible: isVisible,
                    onPressed: () => _showPassword.value = !isVisible,
                  ),
                  validator: (value) => Validators.requiredText(value, 'password'),
                );
              },
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<bool>(
              valueListenable: _rememberMe,
              builder: (context, value, _) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: value,
                  onChanged: (next) async {
                    final shouldRemember = next ?? false;
                    _rememberMe.value = shouldRemember;
                    if (!shouldRemember) {
                      await AuthScope.of(context).clearRememberedCredentials();
                    }
                  },
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppTheme.accent,
                  title: Text('Remember me', style: checkboxStyle),
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _isLoading,
              builder: (context, isLoading, _) {
                return SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_isLoading.value) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _showSnackBar('Please fill in the required fields.');
      return;
    }
    _isLoading.value = true;
    try {
      final result = await AuthScope.of(context).login(
        phone: _phoneController.text,
        password: _passwordController.text,
        rememberMe: _rememberMe.value,
      );
      if (!mounted) return;
      if (!result.isSuccess) {
        await _showErrorDialog(result.message ?? 'Login failed.');
      }
    } finally {
      if (mounted) {
        _isLoading.value = false;
      }
    }
  }

  Future<void> _showErrorDialog(String message, {String title = 'Login failed'}) async {
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
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  static final List<TextInputFormatter> _phoneFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(18),
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;
  late final ValueNotifier<bool> _showPassword;
  late final ValueNotifier<bool> _showConfirmPassword;
  late final ValueNotifier<bool> _isLoading;
  late final ValueNotifier<bool> _canSubmit;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    _showPassword = ValueNotifier<bool>(false);
    _showConfirmPassword = ValueNotifier<bool>(false);
    _isLoading = ValueNotifier<bool>(false);
    _canSubmit = ValueNotifier<bool>(false);
    _firstNameController.addListener(_updateCanSubmit);
    _lastNameController.addListener(_updateCanSubmit);
    _phoneController.addListener(_updateCanSubmit);
    _passwordController.addListener(_updateCanSubmit);
    _confirmController.addListener(_updateCanSubmit);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _showPassword.dispose();
    _showConfirmPassword.dispose();
    _isLoading.dispose();
    _canSubmit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Create account', style: titleStyle),
            const SizedBox(height: 6),
            Text('Join your friends in seconds.', style: subtitleStyle),
            const SizedBox(height: 18),
            _AuthTextField(
              controller: _firstNameController,
              label: 'First name',
              textCapitalization: TextCapitalization.words,
              icon: Icons.person_outline,
              validator: (value) => Validators.requiredText(value, 'first name'),
            ),
            const SizedBox(height: 14),
            _AuthTextField(
              controller: _lastNameController,
              label: 'Last name',
              textCapitalization: TextCapitalization.words,
              icon: Icons.badge_outlined,
              validator: (value) => Validators.requiredText(value, 'last name'),
            ),
            const SizedBox(height: 14),
            _AuthTextField(
              controller: _phoneController,
              label: 'Phone',
              keyboardType: TextInputType.phone,
              inputFormatters: _phoneFormatters,
              icon: Icons.phone_iphone_outlined,
              validator: Validators.phone,
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder<bool>(
              valueListenable: _showPassword,
              builder: (context, isVisible, _) {
                return _AuthTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: !isVisible,
                  isPassword: true,
                  icon: Icons.lock_outline,
                  suffixIcon: _PasswordToggle(
                    isVisible: isVisible,
                    onPressed: () => _showPassword.value = !isVisible,
                  ),
                  validator: (value) => Validators.requiredText(value, 'password'),
                );
              },
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder<bool>(
              valueListenable: _showConfirmPassword,
              builder: (context, isVisible, _) {
                return _AuthTextField(
                  controller: _confirmController,
                  label: 'Confirm password',
                  obscureText: !isVisible,
                  isPassword: true,
                  icon: Icons.check_circle_outline,
                  suffixIcon: _PasswordToggle(
                    isVisible: isVisible,
                    onPressed: () => _showConfirmPassword.value = !isVisible,
                  ),
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _isLoading,
              builder: (context, isLoading, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _canSubmit,
                  builder: (context, canSubmit, __) {
                    final enabled = canSubmit && !isLoading;
                    return SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: enabled ? _handleRegister : null,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Create account'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateCanSubmit() {
    final hasNames = _firstNameController.text.trim().isNotEmpty && _lastNameController.text.trim().isNotEmpty;
    final hasPhone = _phoneController.text.trim().isNotEmpty;
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final passwordsMatch = password.isNotEmpty && password == confirm;
    _canSubmit.value = hasNames && hasPhone && passwordsMatch;
  }

  Future<void> _handleRegister() async {
    if (_isLoading.value) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _showSnackBar('Please fix the errors.');
      return;
    }
    if (!_canSubmit.value) {
      _showSnackBar('Passwords must match.');
      return;
    }
    _isLoading.value = true;
    try {
      final result = await AuthScope.of(context).register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (result.isSuccess) {
        _clearFields();
        _showSnackBar(result.message ?? 'Account created. Please sign in.');
        DefaultTabController.of(context).animateTo(0);
      } else {
        await _showErrorDialog(result.message ?? 'Registration failed.');
      }
    } finally {
      if (mounted) {
        _isLoading.value = false;
      }
    }
  }

  void _clearFields() {
    _firstNameController.clear();
    _lastNameController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmController.clear();
    _updateCanSubmit();
  }

  Future<void> _showErrorDialog(String message, {String title = 'Registration failed'}) async {
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
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.isPassword = false,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.suffixIcon,
    this.icon,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool isPassword;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final IconData? icon;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _PasswordToggle extends StatelessWidget {
  const _PasswordToggle({
    required this.isVisible,
    required this.onPressed,
  });

  final bool isVisible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: isVisible ? 'Hide' : 'Show',
      icon: Icon(
        isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      ),
    );
  }
}
