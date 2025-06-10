import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../../theme_manager.dart';
import '../verification/verification.dart';
import '../../../variable.dart';

/// Home content page with responsive design and smooth animations
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _buttonController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Fade animation for overall content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    // Scale animation for image
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));

    // Button animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut));
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _navigateToVerification() async {
    // Button press animation
    await _buttonController.forward();
    _buttonController.reverse();
    
    if (mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const Verification(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildResponsiveContent(context, constraints);
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveContent(BuildContext context, BoxConstraints constraints) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isMobile = screenWidth < 400;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildAnimatedImage(isMobile, isTablet),
          SizedBox(height: isMobile ? 30 : 40),
          SlideTransition(
            position: _slideAnimation,
            child: _buildContentSection(isMobile, isTablet),
          ),
          const SizedBox(height: 40),
          _buildFeatureCards(isMobile),
        ],
      ),
    );
  }

  Widget _buildAnimatedImage(bool isMobile, bool isTablet) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              // color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            isMobile ? 'assets/images/banner.png' : 'assets/images/Home (2).png',
            height: isMobile ? 250 : (isTablet ? 350 : 300),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(bool isMobile, bool isTablet) {
    return Column(
      children: [
        _buildTitle(isMobile, isTablet),
        SizedBox(height: isMobile ? 12 : 16),
        _buildSubtitle(isMobile, isTablet),
        SizedBox(height: isMobile ? 24 : 32),
        _buildActionButton(isMobile, isTablet),
      ],
    );
  }

  Widget _buildTitle(bool isMobile, bool isTablet) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Text(
          S.of(context).homeTitle, // Localized text
          // 'Make sure your signatures are correct.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 20 : (isTablet ? 28 : 24),
            color: AppColors.getTextPrimary(context),
            // color: const Color(0xFF1B225B),
            height: 1.2,
          ),
        );
      },
    );
  }

  Widget _buildSubtitle(bool isMobile, bool isTablet) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Text(
          S.of(context).homeSubtitle,
          // 'This app scans signatures and ensures their authenticity and safety',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 15 : (isTablet ? 20 : 17),
            color: AppColors.getTextSecondary(context),
            // color: Colors.grey[600],
            height: 1.4,
          ),
        );
      },
    );
  }

  Widget _buildActionButton(bool isMobile, bool isTablet) {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            height: isMobile ? 50 : 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [address, darkest],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: address.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _navigateToVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    S.of(context).signatureVerification,
                    // 'Signature Verification',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : (isTablet ? 22 : 20),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildFeatureCards(bool isMobile) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      )),
      child: Column(
        children: [
          Text(
            S.of(context).whyChooseOurApp,
            // 'Why Choose Our App?',
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(context),
              // color: const Color(0xFF1B225B),
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureCardRow(isMobile),
        ],
      ),
    );
  }

  Widget _buildFeatureCardRow(bool isMobile) {
    final features = [
      {
        'icon': Icons.security_outlined,
        'title': S.of(context).featureSecure,
        'description': S.of(context).featureSecureDesc,
      },
      {
        'icon': Icons.speed_outlined,
        'title': S.of(context).featureFast,
        'description': S.of(context).featureFastDesc,
      },
      {
        'icon': Icons.verified_outlined,
        'title': S.of(context).featureAccurate,
        'description': S.of(context).featureAccurateDesc,
      },
    ];

    if (isMobile) {
      return Column(
        children: features.map((feature) => _buildFeatureCard(feature, isMobile)).toList(),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: features.map((feature) => 
          Expanded(child: _buildFeatureCard(feature, isMobile))
        ).toList(),
      );
    }
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : 8,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        // color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            // color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: address.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature['icon'] as IconData,
              color: address,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            feature['title'] as String,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              // color: Color(0xFF1B225B),
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feature['description'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(context),
              // color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}