import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart';
import '../../../locale_manager.dart';
import '../../../theme_manager.dart';
import '../Change pass/changepass.dart';
import '../LogIn/log_in.dart';
import '../Privacy/PrivacyPolicyPage.dart';

/// Enhanced Settings page with responsive design, smooth animations, and dark mode
class SettingContent extends StatefulWidget {
  const SettingContent({super.key});

  @override
  State<SettingContent> createState() => _SettingContentState();
}

class _SettingContentState extends State<SettingContent>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _itemsController;
  late AnimationController _languageController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _itemsAnimation;
  late Animation<double> _languageSlideAnimation;

  // State variables
  bool _isLanguageExpanded = false;
  // String _selectedLanguage = 'English';
  bool _isLoading = false;

  // Setting items data with dark mode toggle added
  List<SettingItem> get _settingItems => [
    SettingItem(
        icon: Icons.language_rounded,
        label: S.of(context).languages,
        type: SettingItemType.expandable,
        subtitle: S.of(context).languagesSubtitle,
      ),
    SettingItem(
        icon: Icons.dark_mode_outlined,
        label: S.of(context).darkMode,
        type: SettingItemType.toggle,
        subtitle: S.of(context).darkModeSubtitle,
      ),
      SettingItem(
        icon: Icons.security_outlined,
        label: S.of(context).privacyPolicy,
        type: SettingItemType.navigation,
        subtitle: S.of(context).privacyPolicySubtitle,
        navigationTarget: NavigationTarget.privacy,
      ),
      SettingItem(
        icon: Icons.lock_outline_rounded,
        label: S.of(context).changePassword,
        type: SettingItemType.navigation,
        subtitle: S.of(context).changePasswordSubtitle,
        navigationTarget: NavigationTarget.changePassword,
      ),
      SettingItem(
        icon: Icons.help_outline_rounded,
        label: S.of(context).helpSupport,
        type: SettingItemType.action,
        subtitle: S.of(context).helpSupportSubtitle,
      ),
      SettingItem(
        icon: Icons.info_outline_rounded,
        label: S.of(context).about,
        type: SettingItemType.action,
        subtitle: S.of(context).aboutSubtitle,
      ),
      SettingItem(
        icon: Icons.logout_rounded,
        label: S.of(context).logout,
        type: SettingItemType.logout,
        subtitle: S.of(context).logoutSubtitle,
        isDestructive: true,
      ),
    // const SettingItem(
    //   icon: Icons.language_rounded,
    //   label: 'Languages',
    //   type: SettingItemType.expandable,
    //   subtitle: 'Choose your preferred language',
    // ),
    // const SettingItem(
    //   icon: Icons.dark_mode_outlined,
    //   label: 'Dark Mode',
    //   type: SettingItemType.toggle,
    //   subtitle: 'Switch between light and dark themes',
    // ),
    // const SettingItem(
    //   icon: Icons.security_outlined,
    //   label: 'Privacy Policy',
    //   type: SettingItemType.navigation,
    //   subtitle: 'Read our privacy and data policies',
    //   navigationTarget: NavigationTarget.privacy,
    // ),
    // const SettingItem(
    //   icon: Icons.lock_outline_rounded,
    //   label: 'Change Password',
    //   type: SettingItemType.navigation,
    //   subtitle: 'Update your account password',
    //   navigationTarget: NavigationTarget.changePassword,
    // ),
    // const SettingItem(
    //   icon: Icons.help_outline_rounded,
    //   label: 'Help & Support',
    //   type: SettingItemType.action,
    //   subtitle: 'Get help and contact support',
    // ),
    // const SettingItem(
    //   icon: Icons.info_outline_rounded,
    //   label: 'About',
    //   type: SettingItemType.action,
    //   subtitle: 'App version and information',
    // ),
    // const SettingItem(
    //   icon: Icons.logout_rounded,
    //   label: 'Log Out',
    //   type: SettingItemType.logout,
    //   subtitle: 'Sign out of your account',
    //   isDestructive: true,
    // ),
  ];
  

  final List<LanguageOption> _languages = [
    const LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    const LanguageOption(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇪🇬',
    ),
  ];

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

    _itemsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _itemsAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _itemsController, curve: Curves.easeOutBack));

    _languageController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _languageSlideAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _languageController, curve: Curves.easeOutCubic));
  }

  Future<void> _startAnimationSequence() async {
    if (!mounted) return;
    
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _slideController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _itemsController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _itemsController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  void _toggleLanguageList() {
    HapticFeedback.lightImpact();
    setState(() {
      _isLanguageExpanded = !_isLanguageExpanded;
    });
    
    if (_isLanguageExpanded) {
      _languageController.forward();
    } else {
      _languageController.reverse();
    }
  }

  // void _selectLanguage(LanguageOption language) {
  //   if (_selectedLanguage == language.name) return;
    
  //   HapticFeedback.selectionClick();
  //   setState(() {
  //     _selectedLanguage = language.name;
  //   });
    
  //   // Close language list with animation
  //   _languageController.reverse().then((_) {
  //     if (mounted) {
  //       setState(() {
  //         _isLanguageExpanded = false;
  //       });
  //     }
  //   });
    
  //   _showLanguageChangedFeedback(language);
  // }
   void _selectLanguage(LanguageOption language) {
    final localeManager = Provider.of<LocaleManager>(context, listen: false);
    
    // Check if already selected
    if (localeManager.currentLocale.languageCode == language.code) return;
    
    HapticFeedback.selectionClick();
    localeManager.setLocale(Locale(language.code));
    
    // Close language list with animation
    _languageController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isLanguageExpanded = false;
        });
      }
    });
    
    _showLanguageChangedFeedback(language);
  }

  void _showLanguageChangedFeedback(LanguageOption language) {
    final l10n = S.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(language.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.languageChanged(language.name),
                // 'Language changed to ${language.name}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.primary,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleSettingTap(SettingItem item, int index) async {
    // Provide haptic feedback
    HapticFeedback.lightImpact();
    
    // Add loading state for navigation items
    if (item.type == SettingItemType.navigation) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    try {
      switch (item.type) {
        case SettingItemType.navigation:
          await _navigateToPage(item);
          break;
        case SettingItemType.expandable:
          _toggleLanguageList();
          break;
        case SettingItemType.toggle:
          if (item.label == 'Dark Mode') {
            _toggleDarkMode();
          }
          break;
        case SettingItemType.action:
          _handleAction(item.label);
          break;
        case SettingItemType.logout:
          _showLogoutDialog();
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleDarkMode() {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    themeManager.toggleTheme();
    
    final l10n = S.of(context)!;
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.darkModeActivated(
                themeManager.isDarkMode ? l10n.dark : l10n.light
              ),
              // '${themeManager.isDarkMode ? 'Dark' : 'Light'} mode activated',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.primary,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _navigateToPage(SettingItem item) async {
    Widget? targetPage;
    
    switch (item.navigationTarget) {
      case NavigationTarget.privacy:
        targetPage = const PrivacyPolicyPage();
        break;
      case NavigationTarget.changePassword:
        targetPage = const Changepass();
        break;
      case null:
        break;
    }

    if (targetPage != null && mounted) {
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetPage!,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  void _handleAction(String label) {
    switch (label) {
      case 'Help & Support':
        _showHelpDialog();
        break;
      case 'About':
        _showAboutDialog();
        break;
    }
  }
  void _showHelpDialog() {
    final l10n = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(l10n.helpSupportTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.helpContent),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.email_outlined, size: 20),
                SizedBox(width: 8),
                Text('support@inksentinel.com'),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.phone_outlined, size: 20),
                SizedBox(width: 8),
                Text('+1 (555) 123-4567'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
  void _showAboutDialog() {
    final l10n = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(l10n.aboutTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.version),
            const SizedBox(height: 16),
            Text(l10n.builtWith),
            const SizedBox(height: 8),
            Text(l10n.copyright),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
  void _showLogoutDialog() {
    final l10n = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 12),
            Text(l10n.confirmLogoutTitle),
          ],
        ),
        content: Text(l10n.confirmLogoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => _performLogout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.logoutAction),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    Navigator.pop(context); // Close dialog
    
    // Add loading state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    // Simulate logout process
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LogIn(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return _buildResponsiveContent(context, constraints);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveContent(BuildContext context, BoxConstraints constraints) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          SlideTransition(
            position: _slideAnimation,
            child: _buildHeader(isMobile),
          ),
          const SizedBox(height: 24),
          _buildSettingsCard(isMobile),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  Widget _buildHeader(bool isMobile) {
    final l10n = S.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsTitle,
          style: TextStyle(
            fontSize: isMobile ? 28 : 32,
            fontWeight: FontWeight.w800,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsSubtitle,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            color: AppColors.getTextSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(bool isMobile) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getSurface(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            ..._buildAnimatedSettingItems(isMobile),
            if (_isLanguageExpanded) _buildLanguageSelection(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedSettingItems(bool isMobile) {
    return _settingItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      
      return AnimatedBuilder(
        animation: _itemsAnimation,
        builder: (context, child) {
          final delay = index * 0.08;
          final adjustedValue = (_itemsAnimation.value - delay).clamp(0.0, 1.0);
          final animationValue = Curves.easeOutBack.transform(adjustedValue);
          
          final opacity = animationValue.clamp(0.0, 1.0);
          final translateY = 50.0 * (1.0 - animationValue).clamp(0.0, 1.0);
          
          return Transform.translate(
            offset: Offset(0, translateY),
            child: Opacity(
              opacity: opacity,
              child: _buildSettingItem(item, index, isMobile),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildSettingItem(SettingItem item, int index, bool isMobile) {
    final isLast = index == _settingItems.length - 1;
    
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.08)
                : Colors.grey.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : () => _handleSettingTap(item, index),
          borderRadius: BorderRadius.vertical(
            top: index == 0 ? const Radius.circular(16) : Radius.zero,
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildSettingIcon(item),
                const SizedBox(width: 16),
                Expanded(child: _buildSettingContent(item, isMobile)),
                _buildTrailingWidget(item),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingIcon(SettingItem item) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: item.isDestructive 
            ? Colors.red.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        item.icon,
        color: item.isDestructive 
            ? Colors.red
            : AppColors.primary,
        size: 22,
      ),
    );
  }

  Widget _buildSettingContent(SettingItem item, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: TextStyle(
            fontSize: isMobile ? 16 : 17,
            fontWeight: FontWeight.w600,
            color: item.isDestructive 
                ? Colors.red
                : AppColors.getTextPrimary(context),
          ),
        ),
        if (item.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            item.subtitle!,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrailingWidget(SettingItem item) {
    if (_isLoading && item.type == SettingItemType.navigation) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    switch (item.type) {
      case SettingItemType.expandable:
        return AnimatedRotation(
          turns: _isLanguageExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 300),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.getTextSecondary(context),
          ),
        );
      case SettingItemType.navigation:
        return Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppColors.getTextSecondary(context),
        );
      case SettingItemType.toggle:
        if (item.label == 'Dark Mode') {
          return Consumer<ThemeManager>(
            builder: (context, themeManager, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Switch.adaptive(
                  key: ValueKey(themeManager.isDarkMode),
                  value: themeManager.isDarkMode,
                  onChanged: (value) => _toggleDarkMode(),
                  activeColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withOpacity(0.3),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLanguageSelection() {
    final localeManager = Provider.of<LocaleManager>(context, listen: true);
    final currentLanguageCode = localeManager.currentLocale.languageCode;
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.3),
        end: Offset.zero,
      ).animate(_languageSlideAnimation),
      child: FadeTransition(
        opacity: _languageSlideAnimation,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: _languages.asMap().entries.map((entry) {
              final index = entry.key;
              final language = entry.value;
              final isLast = index == _languages.length - 1;
              final isSelected = currentLanguageCode == language.code;
              
              // return _buildLanguageOption(language, isLast);
              return _buildLanguageOption(language, isLast, isSelected);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(LanguageOption language, bool isLast, bool isSelected) {    
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectLanguage(language),
          borderRadius: BorderRadius.vertical(
            top: _languages.first == language ? const Radius.circular(12) : Radius.zero,
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  language.flag,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected 
                              ? AppColors.primary
                              : AppColors.getTextPrimary(context),
                        ),
                      ),
                      if (language.nativeName != language.name)
                        Text(
                          language.nativeName,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced data models
class SettingItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final SettingItemType type;
  final NavigationTarget? navigationTarget;
  final bool isDestructive;

  const SettingItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.type,
    this.navigationTarget,
    this.isDestructive = false,
  });
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

enum SettingItemType {
  navigation,
  expandable,
  action,
  logout,
  toggle, // Added toggle type for switches
}

enum NavigationTarget {
  privacy,
  changePassword,
}