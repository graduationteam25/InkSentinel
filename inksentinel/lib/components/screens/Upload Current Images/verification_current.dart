import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../upload.dart/scancurr.dart';
import '../../../generated/l10n.dart';
import '../../../theme_manager.dart';

class VerificationCurrent extends StatelessWidget {
  final String originalImagePath;
  final File imageFile;
  
  const VerificationCurrent({
    super.key,
    required this.originalImagePath,
    required this.imageFile
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: CurrentSignatureVerification(
        originalImagePath: originalImagePath,
        imageFile: imageFile,
      ),
    );
  }
}

class CurrentSignatureVerification extends StatefulWidget {
  final String originalImagePath;
  final File imageFile;
  
  const CurrentSignatureVerification({
    super.key,
    required this.originalImagePath,
    required this.imageFile
  });

  @override
  State<CurrentSignatureVerification> createState() => 
      _CurrentSignatureVerificationState();
}

class _CurrentSignatureVerificationState extends State<CurrentSignatureVerification>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _buttonController;
  late AnimationController _cardController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _cardPulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut));

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardPulseAnimation = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _cardController, curve: Curves.easeInOut));
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    _cardController.repeat(reverse: true);
  }

  void _handleUploadImage() async {
    await _buttonController.forward();
    _buttonController.reverse();
    
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
          child: Wrap(
            children: [Scancurr(
              originalImagePath: widget.originalImagePath,
              imageFile: widget.imageFile,
            )],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _buttonController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.isDarkMode;
    
    return Scaffold(
      appBar: _buildAppBar(context, isDarkMode),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return _buildResponsiveContent(context, constraints, isDarkMode);
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      title: Text(
        S.of(context).signatureVerification,
        style: TextStyle(
          color: AppColors.getTextPrimary(context),
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.getSurface(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadowColor(context),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      systemOverlayStyle: isDarkMode 
          ? SystemUiOverlayStyle.light 
          : SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildResponsiveContent(
    BuildContext context, 
    BoxConstraints constraints,
    bool isDarkMode
  ) {
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
          const SizedBox(height: 10),
          SlideTransition(
            position: _slideAnimation,
            child: _buildHeaderSection(isMobile, isTablet),
          ),
          SizedBox(height: isMobile ? 30 : 40),
          _buildAnimatedPreviewCard(isMobile, isTablet, isDarkMode),
          SizedBox(height: isMobile ? 24 : 32),
          _buildActionButton(isMobile, isTablet),
          const SizedBox(height: 30),
          _buildVerificationInfoCards(isMobile, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(bool isMobile, bool isTablet) {
    return Column(
      children: [
        Text(
          S.of(context).uploadCurrentSignature,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 22 : (isTablet ? 28 : 26),
            color: AppColors.getTextPrimary(context),
            height: 1.2,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Text(
          S.of(context).uploadCurrentSignatureDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 15 : (isTablet ? 18 : 16),
            color: AppColors.getTextSecondary(context),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedPreviewCard(
    bool isMobile, 
    bool isTablet,
    bool isDarkMode
  ) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _cardPulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _cardPulseAnimation.value,
            child: GestureDetector(
              onTap: _handleUploadImage,
              child: Container(
                height: isMobile ? 280 : (isTablet ? 350 : 320),
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.getSurface(context),
                      isDarkMode 
                        ? Colors.grey[850]!.withOpacity(0.5)
                        : const Color(0xffE6F5F5).withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    if (!isDarkMode)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.compare_arrows_rounded,
                        size: isMobile ? 60 : 80,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).compareWithOriginal,
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).tapToUploadCurrentSignature,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
            height: isMobile ? 56 : 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [AppColors.primary, const Color(0xFF1B225B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _handleUploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    S.of(context).uploadCurrentSignatureButton,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
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

  Widget _buildVerificationInfoCards(bool isMobile, bool isDarkMode) {
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
            S.of(context).verificationProcess,
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCardRow(isMobile, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildInfoCardRow(bool isMobile, bool isDarkMode) {
    final infoItems = [
      {
        'icon': Icons.verified_user_outlined,
        'title': S.of(context).originalSignature,
        'description': S.of(context).originalSignatureDescription,
      },
      {
        'icon': Icons.compare_arrows_rounded,
        'title': S.of(context).patternMatching,
        'description': S.of(context).patternMatchingDescription,
      },
      {
        'icon': Icons.security_outlined,
        'title': S.of(context).secureResults,
        'description': S.of(context).secureResultsDescription,
      },
    ];

    if (isMobile) {
      return Column(
        children: infoItems.map((item) => 
          _buildInfoCard(item, isMobile, isDarkMode)
        ).toList(),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: infoItems.map((item) => 
          Expanded(child: _buildInfoCard(item, isMobile, isDarkMode))
        ).toList(),
      );
    }
  }

  Widget _buildInfoCard(
    Map<String, dynamic> item, 
    bool isMobile,
    bool isDarkMode
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : 8,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(context),
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
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item['icon'] as IconData,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item['title'] as String,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item['description'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}