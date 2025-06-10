import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inksentinel/generated/l10n.dart';
import 'package:provider/provider.dart';
import '../../../theme_manager.dart';

class Forgetpage extends StatefulWidget {
  const Forgetpage({super.key});

  @override
  State<Forgetpage> createState() => _ForgetpageState();
}

class _ForgetpageState extends State<Forgetpage> 
    with TickerProviderStateMixin {
  
  // Controllers and form state
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shakeController;
  late AnimationController _successController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _successAnimation;

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

    // Success animation
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _successAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _successController, curve: Curves.elasticOut));
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
    _fadeController.dispose();
    _slideController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    super.dispose();
  }

  /// Handle password reset request
  Future<void> _resetPassword() async {
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
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
      
      _successController.forward();
      
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(_getErrorMessage(s, e.code));
      _triggerShakeAnimation();
    } catch (e) {
      _showErrorMessage(s.unexpectedError);
      _triggerShakeAnimation();
    } finally {
      if (mounted && !_emailSent) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Get user-friendly error messages
  String _getErrorMessage(S s, String code) {
    switch (code) {
      case 'user-not-found': return s.userNotFound;
      case 'invalid-email': return s.invalidEmail;
      case 'too-many-requests': return s.tooManyRequests;
      default: return s.resetFailed;
    }
  }

  void _showErrorMessage(String message) {
    setState(() => _errorMessage = message);
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) => _shakeController.reset());
  }

  /// Resend password reset email
  void _resendEmail() {
    setState(() {
      _emailSent = false;
      _errorMessage = null;
    });
    _successController.reset();
    _resetPassword();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.isDarkMode;
    final s = S.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.getTextPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.resetPassword,
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          kToolbarHeight - 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_emailSent) ...[
                    _buildHeader(s),
                    const SizedBox(height: 48),
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildResetForm(s, isDarkMode),
                    ),
                  ] else ...[
                    _buildSuccessContent(s, isDarkMode),
                  ],
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
        // Forgot password icon with animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.8, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF259FA2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: const Color(0xFF259FA2).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.lock_reset,
                  color: Color(0xFF259FA2),
                  size: 50,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          s.forgotPassword,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          s.resetInstructions,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.getSubtitleColor(context),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildResetForm(S s, bool isDarkMode) {
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
                  const SizedBox(height: 16),
                  _buildErrorMessage(isDarkMode),
                  const SizedBox(height: 24),
                  _buildResetButton(s),
                  const SizedBox(height: 20),
                  _buildBackToLoginLink(s),
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

  Widget _buildResetButton(S s) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _resetPassword,
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
                s.sendResetLink,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToLoginLink(S s) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        s.backToSignIn,
        style: const TextStyle(
          color: Color(0xFF259FA2),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSuccessContent(S s, bool isDarkMode) {
    return ScaleTransition(
      scale: _successAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 60,
            ),
          ),
          const SizedBox(height: 32),
          
          // Success title
          Text(
            s.checkEmail,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          
          // Success message
          Text(
            '${s.resetSent}\n${_emailController.text}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getSubtitleColor(context),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          
          // Action buttons
          Container(
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
            child: Column(
              children: [
                // Open email app button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF259FA2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      s.backToSignIn,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Resend email button
                TextButton(
                  onPressed: _resendEmail,
                  child: Text(
                    s.resendEmail,
                    style: const TextStyle(
                      color: Color(0xFF259FA2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}