import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart';
import '../../../theme_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  
  // Animations
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
    _startNavigationTimer();
  }

  void _initAnimations() {
    // Logo fade-in animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    // Overall fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Scale animation for logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));

    // Shimmer effect animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0)
        .animate(CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));
  }

  void _startAnimationSequence() async {
    // Start fade animation
    _fadeController.forward();
    
    // Delay then start logo animations
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    _scaleController.forward();
    
    // Start shimmer effect after logo appears
    await Future.delayed(const Duration(milliseconds: 500));
    _shimmerController.repeat(reverse: true);
  }

  void _startNavigationTimer() {
    _navigationTimer = Timer(const Duration(seconds: 3), _navigateToNextScreen);
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    try {
      // Check authentication state
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null && user.emailVerified) {
        // User is logged in and verified, go to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // User not logged in or not verified, go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // In case of any error, default to login screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _logoController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.isDarkMode;
    final colors = _AppColors(isDarkMode);

    return Scaffold(
      backgroundColor: colors.splashBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _buildGradientBackground(colors),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _buildAnimatedLogo(colors),
                const SizedBox(height: 40),
                _buildAppTitle(),
                const SizedBox(height: 16),
                _buildSubtitle(),
                const Spacer(flex: 2),
                _buildLoadingIndicator(colors),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground(_AppColors colors) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors.splashGradient,
        stops: const [0.0, 0.7, 1.0],
      ),
    );
  }

  Widget _buildAnimatedLogo(_AppColors colors) {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoAnimation, _scaleAnimation, _shimmerAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colors.logoBackground,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: colors.logoShadow,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: colors.logoHighlight,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Logo image
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/Splash_logo2.jpg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Shimmer overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
                          end: Alignment(1.0 + _shimmerAnimation.value, 0.0),
                          colors: [
                            Colors.transparent,
                            colors.shimmerEffect,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppTitle() {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _logoController,
              curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
            )),
            child: Text(
              S.of(context).splashWelcome,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.8),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _logoController,
              curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
            )),
            child: Text(
              S.of(context).splashGettingReady,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(_AppColors colors) {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _logoController,
              curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
            )),
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colors.loadingIndicator,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// App color constants with dark mode support
class _AppColors {
  final bool isDarkMode;

  _AppColors(this.isDarkMode);

  // Splash screen colors
  Color get splashBackground => isDarkMode ? const Color(0xFF121212) : const Color(0xFF1B225B);

  List<Color> get splashGradient => isDarkMode
      ? [
          const Color(0xFF0A0E2D),
          const Color(0xFF0A0E2D).withOpacity(0.9),
          const Color(0xFF0D5F61).withOpacity(0.8),
        ]
      : [
          const Color(0xFF1B225B),
          const Color(0xFF1B225B).withOpacity(0.9),
          const Color(0xFF259FA2).withOpacity(0.8),
        ];

  Color get logoBackground => isDarkMode ? Colors.grey[800]! : Colors.white;
  Color get logoShadow => isDarkMode ? Colors.black : Colors.black.withOpacity(0.3);
  Color get logoHighlight => isDarkMode ? Colors.grey[700]! : Colors.white.withOpacity(0.1);
  Color get shimmerEffect => isDarkMode ? Colors.grey[700]! : Colors.white.withOpacity(0.3);
  Color get loadingIndicator => isDarkMode ? Colors.grey[400]! : Colors.white.withOpacity(0.7);
}