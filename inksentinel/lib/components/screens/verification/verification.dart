import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../upload.dart/scan.dart';
import '../../../generated/l10n.dart';
import '../../../theme_manager.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification>
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _buttonController.dispose();
    _cardController.dispose();
    super.dispose();
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const Wrap(
            children: [ScanTestd('original')],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.isDarkMode;
    final colors = VerificationColors(isDarkMode);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, colors),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return _buildResponsiveContent(context, constraints, colors);
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, VerificationColors colors) {
    return AppBar(
      title: Text(
        S.of(context).verificationTitle,
        style: TextStyle(
          color: colors.textPrimary,
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
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: colors.primary,
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildResponsiveContent(
    BuildContext context, 
    BoxConstraints constraints,
    VerificationColors colors
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
            child: _buildHeaderSection(isMobile, isTablet, colors),
          ),
          SizedBox(height: isMobile ? 30 : 40),
          _buildAnimatedUploadCard(isMobile, isTablet, colors),
          SizedBox(height: isMobile ? 24 : 32),
          _buildActionButton(isMobile, isTablet, colors),
          const SizedBox(height: 30),
          _buildInstructionCards(isMobile, colors),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(bool isMobile, bool isTablet, VerificationColors colors) {
    return Column(
      children: [
        Text(
          S.of(context).uploadOriginalSignature,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 22 : (isTablet ? 28 : 26),
            color: colors.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Text(
          S.of(context).uploadOriginalSignatureDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 15 : (isTablet ? 18 : 16),
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedUploadCard(
    bool isMobile, 
    bool isTablet,
    VerificationColors colors
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
                    colors: colors.uploadCardGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colors.cardBorder,
                    width: 2,
                  ),
                  boxShadow: colors.uploadCardShadows,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.uploadIconBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: isMobile ? 60 : 80,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).tapToUploadImage,
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).dragOrClickInstruction,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: colors.textSecondary,
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

  Widget _buildActionButton(
    bool isMobile, 
    bool isTablet,
    VerificationColors colors
  ) {
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
                colors: colors.buttonGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: colors.buttonShadows,
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
                    color: colors.buttonIcon,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    S.of(context).uploadSignatureButton,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : (isTablet ? 22 : 20),
                      fontWeight: FontWeight.w600,
                      color: colors.buttonText,
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

  Widget _buildInstructionCards(bool isMobile, VerificationColors colors) {
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
            S.of(context).uploadGuidelines,
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildInstructionCardRow(isMobile, colors),
        ],
      ),
    );
  }

  Widget _buildInstructionCardRow(bool isMobile, VerificationColors colors) {
    final instructions = [
      {
        'icon': Icons.high_quality_outlined,
        'title': S.of(context).highQuality,
        'description': S.of(context).highQualityDescription,
      },
      {
        'icon': Icons.wb_sunny_outlined,
        'title': S.of(context).goodLighting,
        'description': S.of(context).goodLightingDescription,
      },
      {
        'icon': Icons.crop_outlined,
        'title': S.of(context).properFrame,
        'description': S.of(context).properFrameDescription,
      },
    ];

    if (isMobile) {
      return Column(
        children: instructions.map((instruction) => 
          _buildInstructionCard(instruction, isMobile, colors)
        ).toList(),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: instructions.map((instruction) => 
          Expanded(child: _buildInstructionCard(instruction, isMobile, colors))
        ).toList(),
      );
    }
  }

  Widget _buildInstructionCard(
    Map<String, dynamic> instruction, 
    bool isMobile,
    VerificationColors colors
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : 8,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: colors.cardShadows,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.cardIconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              instruction['icon'] as IconData,
              color: colors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            instruction['title'] as String,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            instruction['description'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class VerificationColors {
  final bool isDarkMode;

  VerificationColors(this.isDarkMode);

  Color get background => isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
  Color get surface => isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get shadow => isDarkMode ? Colors.black : Colors.black12;
  Color get textPrimary => isDarkMode ? Colors.white : const Color(0xFF1B225B);
  Color get textSecondary => isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  Color get primary => isDarkMode ? const Color(0xFF21A0A3) : const Color(0xFF259FA2);

  List<Color> get uploadCardGradient => isDarkMode
      ? [const Color(0xFF1E1E1E), const Color(0xFF252525)]
      : [Colors.white, const Color(0xffE6F5F5).withOpacity(0.5)];

  List<BoxShadow> get uploadCardShadows => isDarkMode
      ? [BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 20,
          offset: const Offset(0, 10),
        )]
      : [
          BoxShadow(
            color: primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ];

  Color get cardBorder => isDarkMode ? Colors.grey[800]! : primary.withOpacity(0.2);
  Color get uploadIconBackground => isDarkMode ? Colors.grey[800]! : primary.withOpacity(0.1);

  List<Color> get buttonGradient => isDarkMode
      ? [const Color(0xFF1B7A7D), const Color(0xFF146366)]
      : [const Color(0xFF259FA2), const Color(0xFF1B225B)];

  List<BoxShadow> get buttonShadows => isDarkMode
      ? [BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 15,
          offset: const Offset(0, 8),
        )]
      : [BoxShadow(
          color: primary.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        )];

  Color get buttonText => Colors.white;
  Color get buttonIcon => Colors.white;

  List<BoxShadow> get cardShadows => isDarkMode
      ? [BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 10,
          offset: const Offset(0, 5),
        )]
      : [BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        )];

  Color get cardIconBackground => isDarkMode ? Colors.grey[800]! : primary.withOpacity(0.1);
}