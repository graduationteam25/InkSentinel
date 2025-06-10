import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inksentinel/generated/l10n.dart';
import 'package:provider/provider.dart';
import '../../../locale_manager.dart';
import '../../../theme_manager.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> with TickerProviderStateMixin {
  // Controllers and state
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shakeController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startEntryAnimation();
  }

  void _initAnimations() {
    // Fade animation for overall content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Slide animation for form
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    // Shake animation for errors
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn));
  }

  void _startEntryAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // Authentication logic
  Future<void> _signIn() async {
    final s = S.of(context)!;
    
    if (!_formKey.currentState!.validate()) {
      _triggerShakeAnimation();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _showErrorMessage(s.verificationEmailSent);
        return;
      }

      // Success - navigate to main app
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/splash');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(_getErrorMessage(s, e.code));
      _triggerShakeAnimation();
    } catch (e) {
      _showErrorMessage(s.unexpectedError);
      _triggerShakeAnimation();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(S s, String code) {
    switch (code) {
      case 'user-not-found': return s.userNotFound;
      case 'wrong-password': return s.wrongPassword;
      case 'invalid-email': return s.invalidEmail;
      case 'too-many-requests': return s.tooManyRequests;
      default: return s.loginFailed;
    }
  }

  void _showErrorMessage(String message) {
    setState(() => _errorMessage = message);
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) => _shakeController.reset());
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final localeManager = Provider.of<LocaleManager>(context);
    final isDarkMode = themeManager.isDarkMode;
    final isArabic = localeManager.isArabic;
    final s = S.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(s),
                  const SizedBox(height: 48),
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildLoginForm(s, isDarkMode, isArabic),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(S s) {
    return Column(
      children: [
        // App logo/icon with subtle animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.8, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF259FA2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF259FA2).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          s.welcomeBack,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.signInToContinue,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.getSubtitleColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(S s, bool isDarkMode, bool isArabic) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * 10 * 
                        ((_shakeAnimation.value * 4).floor().isEven ? 1 : -1), 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadowColor(context),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildEmailField(s),
                  const SizedBox(height: 20),
                  _buildPasswordField(s),
                  const SizedBox(height: 16),
                  _buildErrorMessage(isDarkMode),
                  const SizedBox(height: 24),
                  _buildLoginButton(s),
                  const SizedBox(height: 20),
                  _buildForgotPasswordLink(s),
                  const SizedBox(height: 20),
                  _buildSignUpLink(s, isArabic),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailField(S s) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textDirection: TextDirection.ltr, // Email always LTR
      decoration: InputDecoration(
        labelText: s.emailLabel,
        hintText: s.emailHint,
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF259FA2), width: 2),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return s.emailRequired;
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
          return s.emailInvalid;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(S s) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textDirection: TextDirection.ltr, // Password always LTR
      decoration: InputDecoration(
        labelText: s.passwordLabel,
        hintText: s.passwordHint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF259FA2), width: 2),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return s.passwordRequired;
        if (value!.length < 6) return s.passwordTooShort;
        return null;
      },
    );
  }

  Widget _buildErrorMessage(bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _errorMessage != null ? 40 : 0,
      child: _errorMessage != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.red[900] : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDarkMode ? Colors.red[700]! : Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: isDarkMode ? Colors.red[300] : Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: isDarkMode ? Colors.red[100] : Colors.red[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildLoginButton(S s) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF259FA2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: _isLoading ? 0 : 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                s.signInButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildForgotPasswordLink(S s) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/forgot');
      },
      child: Text(
        s.forgotPassword,
        style: const TextStyle(
          color: Color(0xFF259FA2),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSignUpLink(S s, bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          s.noAccount,
          style: TextStyle(color: AppColors.getSubtitleColor(context)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            s.signUp,
            style: const TextStyle(
              color: Color(0xFF259FA2),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}