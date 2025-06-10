import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../../../locale_manager.dart';
import '../../../theme_manager.dart';
import '../Home/bar.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<PolicySection> _policySections;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize policy sections with context after dependencies are resolved
    _policySections = _buildPolicySections();
  }

  List<PolicySection> _buildPolicySections() {
    return [
      PolicySection(
        title: S.of(context).policy1Title,
        content: S.of(context).policy1Content,
        icon: Icons.info_outline,
      ),
      PolicySection(
        title: S.of(context).policy2Title,
        content: S.of(context).policy2Content,
        icon: Icons.settings_outlined,
      ),
      PolicySection(
        title: S.of(context).policy3Title,
        content: S.of(context).policy3Content,
        icon: Icons.share_outlined,
      ),
      PolicySection(
        title: S.of(context).policy4Title,
        content: S.of(context).policy4Content,
        icon: Icons.security_outlined,
      ),
      PolicySection(
        title: S.of(context).policy5Title,
        content: S.of(context).policy5Content,
        icon: Icons.account_circle_outlined,
      ),
      PolicySection(
        title: S.of(context).policy6Title,
        content: S.of(context).policy6Content,
        icon: Icons.update_outlined,
      ),
    ];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localeManager = Provider.of<LocaleManager>(context, listen: false);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, localeManager.isArabic),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(context, isDarkMode),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isArabic) {
    return AppBar(
      leading: _AppBarBackButton(
        onPressed: () => _navigateBack(context),
      ),
      title: _AppBarTitle(isArabic: isArabic),
      backgroundColor: AppColors.primary,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDarkMode) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(context),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildAnimatedSection(index, context, isDarkMode),
            childCount: _policySections.length,
          ),
        ),
        SliverToBoxAdapter(
          child: _buildFooter(context),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.privacy_tip_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).privacyPolicyTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).privacyPolicySubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection(int index, BuildContext context, bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: PolicySectionCard(
              section: _policySections[index],
              index: index,
              isDarkMode: isDarkMode,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Text(
            S.of(context).privacyLastUpdated,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).privacyContact,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _navigateBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BasePageLayout(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _AppBarBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AppBarBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  final bool isArabic;

  const _AppBarTitle({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isArabic) const Icon(Icons.security_outlined, color: Colors.white),
        const SizedBox(width: 12),
        Text(
          S.of(context).privacyPolicy,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        if (isArabic) ...[
          const SizedBox(width: 12),
          const Icon(Icons.security_outlined, color: Colors.white),
        ],
      ],
    );
  }
}

class PolicySectionCard extends StatefulWidget {
  final PolicySection section;
  final int index;
  final bool isDarkMode;

  const PolicySectionCard({
    super.key,
    required this.section,
    required this.index,
    required this.isDarkMode,
  });

  @override
  State<PolicySectionCard> createState() => _PolicySectionCardState();
}

class _PolicySectionCardState extends State<PolicySectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              elevation: _isExpanded ? 8 : 3,
              borderRadius: BorderRadius.circular(16),
              shadowColor: AppColors.primary.withOpacity(0.3),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _toggleExpansion,
                onTapDown: (_) => _hoverController.forward(),
                onTapUp: (_) => _hoverController.reverse(),
                onTapCancel: () => _hoverController.reverse(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: _isExpanded
                        ? Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          )
                        : null,
                    color: widget.isDarkMode 
                        ? Colors.grey[850] 
                        : Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: _buildExpandedContent(context),
                        crossFadeState: _isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.section.icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            widget.section.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff259fa2),
            ),
          ),
        ),
        AnimatedRotation(
          turns: _isExpanded ? 0.5 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primary.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.section.content,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: AppColors.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
}

class PolicySection {
  final String title;
  final String content;
  final IconData icon;

  const PolicySection({
    required this.title,
    required this.content,
    required this.icon,
  });
}