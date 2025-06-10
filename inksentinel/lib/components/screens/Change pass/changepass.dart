import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inksentinel/generated/l10n.dart';
import 'package:provider/provider.dart';
import '../../../theme_manager.dart';
import '../Home/bar.dart';

class Changepass extends StatelessWidget {
  const Changepass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BasePageLayout()),
          ),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          iconSize: 24,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF259FA2),
        title: Text(
          S.of(context).changePassword,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF259FA2),
                Color(0xFF21A3A6),
              ],
            ),
          ),
        ),
      ),
      body: Design(isDarkMode: isDarkMode),
    );
  }
}

class Design extends StatefulWidget {
  final bool isDarkMode;
  
  const Design({super.key, required this.isDarkMode});

  @override
  State<Design> createState() => _DesignState();
}

class _DesignState extends State<Design> with TickerProviderStateMixin {
  // Controllers and state
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shakeController;
  late AnimationController _buttonController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _buttonScaleAnimation;

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

    // Button animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut));
  }

  void _startEntryAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _shakeController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  // Password change logic
  Future<void> _changePassword() async {
    final s = S.of(context)!;
    
    if (!_formKey.currentState!.validate()) {
      _triggerShakeAnimation();
      return;
    }

    // Additional validation
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      _showErrorMessage(s.passwordsDontMatch);
      _triggerShakeAnimation();
      return;
    }

    if (newPassword.length < 8) {
      _showErrorMessage(s.passwordTooShort);
      _triggerShakeAnimation();
      return;
    }

    if (!_isPasswordStrong(newPassword)) {
      _showErrorMessage(s.passwordComplexity);
      _triggerShakeAnimation();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        _showErrorMessage(s.noUserLoggedIn);
        return;
      }

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      _showSuccessMessage(s.passwordUpdated);
      
      // Clear form after success
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

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
      case 'wrong-password': return s.incorrectPassword;
      case 'requires-recent-login': return s.recentLoginRequired;
      case 'weak-password': return s.weakPassword;
      case 'too-many-requests': return s.tooManyRequests;
      default: return s.passwordUpdateFailed;
    }
  }

  bool _isPasswordStrong(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(password);
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
      _successMessage = null;
    });
  }

  void _showSuccessMessage(String message) {
    setState(() {
      _successMessage = message;
      _errorMessage = null;
    });
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) => _shakeController.reset());
  }

  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength;
  }

  Color _getStrengthColor(int strength) {
    final isDarkMode = widget.isDarkMode;
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final isDarkMode = widget.isDarkMode;

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
                    child: _buildPasswordForm(s, isDarkMode),
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
        // Security icon with subtle animation
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
                  Icons.security,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          s.secureAccount,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.createStrongPassword,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.getSubtitleColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm(S s, bool isDarkMode) {
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
                  _buildPasswordField(
                    s.currentPassword,
                    s.currentPasswordHint,
                    _currentPasswordController,
                    _isCurrentPasswordVisible,
                    (value) => setState(() => _isCurrentPasswordVisible = value),
                    (value) {
                      if (value?.isEmpty ?? true) return s.currentPasswordRequired;
                      return null;
                    },
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    s.newPassword,
                    s.newPasswordHint,
                    _newPasswordController,
                    _isNewPasswordVisible,
                    (value) => setState(() => _isNewPasswordVisible = value),
                    (value) {
                      if (value?.isEmpty ?? true) return s.newPasswordRequired;
                      if (value!.length < 8) return s.passwordTooShort;
                      return null;
                    },
                    showStrengthIndicator: true,
                    isDarkMode: isDarkMode,
                    s: s,
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    s.confirmPassword,
                    s.confirmPasswordHint,
                    _confirmPasswordController,
                    _isConfirmPasswordVisible,
                    (value) => setState(() => _isConfirmPasswordVisible = value),
                    (value) {
                      if (value?.isEmpty ?? true) return s.confirmPasswordRequired;
                      if (value != _newPasswordController.text) return s.passwordsDontMatch;
                      return null;
                    },
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  _buildMessageArea(isDarkMode),
                  const SizedBox(height: 24),
                  _buildSaveButton(s),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField(
    String label,
    String hint,
    TextEditingController controller,
    bool isVisible,
    Function(bool) onVisibilityToggle,
    String? Function(String?) validator, {
    bool showStrengthIndicator = false,
    bool isDarkMode = false,
    S? s,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          textDirection: TextDirection.ltr, // Password always LTR
          onChanged: showStrengthIndicator ? (_) => setState(() {}) : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => onVisibilityToggle(!isVisible),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF259FA2), width: 2),
            ),
          ),
          validator: validator,
        ),
        if (showStrengthIndicator && s != null) ...[
          const SizedBox(height: 8),
          _buildPasswordStrengthIndicator(isDarkMode, s),
        ],
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator(bool isDarkMode, S s) {
    final password = _newPasswordController.text;
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
                        ? _getStrengthColor(strength)
                        : isDarkMode ? Colors.grey[700] : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          if (password.isNotEmpty)
            Text(
              _getStrengthText(s, strength),
              style: TextStyle(
                fontSize: 12,
                color: _getStrengthColor(strength),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageArea(bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: (_errorMessage != null || _successMessage != null) ? 40 : 0,
      child: (_errorMessage != null || _successMessage != null)
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _successMessage != null 
                  ? (isDarkMode ? Colors.green[900] : Colors.green[50])
                  : (isDarkMode ? Colors.red[900] : Colors.red[50]),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _successMessage != null 
                    ? (isDarkMode ? Colors.green[700]! : Colors.green[200]!)
                    : (isDarkMode ? Colors.red[700]! : Colors.red[200]!),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _successMessage != null ? Icons.check_circle : Icons.warning,
                    color: _successMessage != null 
                      ? (isDarkMode ? Colors.green[300] : Colors.green[600])
                      : (isDarkMode ? Colors.red[300] : Colors.red[600]),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _successMessage ?? _errorMessage!,
                      style: TextStyle(
                        color: _successMessage != null 
                          ? (isDarkMode ? Colors.green[100] : Colors.green[700])
                          : (isDarkMode ? Colors.red[100] : Colors.red[700]),
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

  Widget _buildSaveButton(S s) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isLoading ? null : () async {
            _buttonController.forward().then((_) => _buttonController.reverse());
            await _changePassword();
          },
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
                  s.updatePassword,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}