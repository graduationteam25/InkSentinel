import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inksentinel/generated/l10n.dart';
import 'package:provider/provider.dart';
import '../../../theme_manager.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  // Controllers and form state
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // UI state
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
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
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // Password strength validation methods
  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength;
  }

  Color _getStrengthColor(int strength, bool isDarkMode) {
    switch (strength) {
      case 0:
      case 1:
        return isDarkMode ? Colors.red[400]! : Colors.red;
      case 2:
        return isDarkMode ? Colors.orange[300]! : Colors.orange;
      case 3:
        return isDarkMode ? Colors.yellow[600]! : Colors.yellow[700]!;
      case 4:
        return isDarkMode ? Colors.green[400]! : Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Handle user registration
  Future<void> _signUp() async {
    final s = S.of(context)!;
    
    if (!_formKey.currentState!.validate()) {
      _triggerShakeAnimation();
      return;
    }

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorMessage(s.passwordsDontMatch);
      _triggerShakeAnimation();
      return;
    }

    // Check password strength (only allow good or strong passwords)
    final passwordStrength = _calculatePasswordStrength(_passwordController.text);
    if (passwordStrength < 3) {
      _showErrorMessage(s.passwordStrengthWarning);
      _triggerShakeAnimation();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create user account
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Show success message
      if (mounted) {
        _showSuccessDialog(s);
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

  /// Get user-friendly error messages
  String _getErrorMessage(S s, String code) {
    switch (code) {
      case 'weak-password': return s.weakPassword;
      case 'email-already-in-use': return s.emailAlreadyInUse;
      case 'invalid-email': return s.invalidEmail;
      case 'operation-not-allowed': return s.operationNotAllowed;
      default: return s.registrationFailed;
    }
  }

  void _showErrorMessage(String message) {
    setState(() => _errorMessage = message);
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) => _shakeController.reset());
  }

  /// Show success dialog after registration
  void _showSuccessDialog(S s) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: AppColors.getSurface(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Text(s.accountCreated),
            ],
          ),
          content: Text(
            s.verificationSent,
            style: TextStyle(color: AppColors.getTextSecondary(context)),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushReplacementNamed(context, '/login'); // Go to login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF259FA2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(s.continueToLogin),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.isDarkMode;
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
                    child: _buildSignUpForm(s, isDarkMode),
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
                  Icons.person_add_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          s.createAccount,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.signUpToGetStarted,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.getSubtitleColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm(S s, bool isDarkMode) {
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
                  const SizedBox(height: 8),
                  _buildPasswordStrengthIndicator(s, isDarkMode),
                  const SizedBox(height: 20),
                  _buildConfirmPasswordField(s),
                  const SizedBox(height: 16),
                  _buildErrorMessage(isDarkMode),
                  const SizedBox(height: 24),
                  _buildSignUpButton(s),
                  const SizedBox(height: 20),
                  _buildLoginLink(s),
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
      onChanged: (_) => setState(() {}), // Trigger rebuild for strength indicator
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
        if (value!.length < 8) return s.passwordTooShort;
        
        final strength = _calculatePasswordStrength(value);
        if (strength < 3) {
          return s.passwordStrengthWarning;
        }
        
        return null;
      },
    );
  }

  Widget _buildPasswordStrengthIndicator(S s, bool isDarkMode) {
    final password = _passwordController.text;
    final strength = _calculatePasswordStrength(password);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: index < strength
                        ? _getStrengthColor(strength, isDarkMode)
                        : isDarkMode ? Colors.grey[700] : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          if (password.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getStrengthText(s, strength),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStrengthColor(strength, isDarkMode),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (strength < 3)
                  Text(
                    s.goodStrongRequired,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.orange[300] : Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          if (password.isNotEmpty && strength < 3) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.blue[900] : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDarkMode ? Colors.blue[700]! : Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.passwordShouldInclude,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.blue[200] : Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildPasswordRequirement(s.atLeast8Chars, password.length >= 8),
                  _buildPasswordRequirement(s.uppercaseLetter, password.contains(RegExp(r'[A-Z]'))),
                  _buildPasswordRequirement(s.numberDigit, password.contains(RegExp(r'[0-9]'))),
                  _buildPasswordRequirement(s.specialChar, password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(String requirement, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            requirement,
            style: TextStyle(
              fontSize: 11,
              color: isMet ? Colors.green[700] : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  String _getStrengthText(S s, int strength) {
    switch (strength) {
      case 0:
      case 1: return s.weak;
      case 2: return s.fair;
      case 3: return s.good;
      case 4: return s.strong;
      default: return '';
    }
  }

  Widget _buildConfirmPasswordField(S s) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      textDirection: TextDirection.ltr, // Password always LTR
      decoration: InputDecoration(
        labelText: s.confirmPassword,
        hintText: s.confirmPasswordHint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
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
        if (value?.isEmpty ?? true) return s.confirmPasswordRequired;
        if (value != _passwordController.text) return s.passwordsDontMatch;
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
                  Icon(Icons.warning, 
                      color: isDarkMode ? Colors.red[300] : Colors.red[600], 
                      size: 20),
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

  Widget _buildSignUpButton(S s) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signUp,
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
                s.createAccount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink(S s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          s.alreadyHaveAccount,
          style: TextStyle(color: AppColors.getSubtitleColor(context)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            s.signIn,
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