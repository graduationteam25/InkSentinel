import 'package:flutter/material.dart';
import 'package:inksentinel/generated/l10n.dart';
import '../../../locale_manager.dart';
import '../../../theme_manager.dart';
import '../History/hist.dart';
import '../Home/home.dart';
import '../Sign up/sign_up.dart';
import '../LogIn/log_in.dart';
import '../Setting/setting_content.dart';
import '../help/help_content.dart';
import '../verification/verification.dart';
import 'package:provider/provider.dart';

// Constants for better maintainability
class AppConstants {
  static const primaryColor = Color(0xFF15B7BA);
  static const unselectedColor = Colors.blueGrey;
  static const drawerHeaderColor = Color(0xFF15B7BA);
  static const toolbarHeight = 50.0;
  static const iconSize = 30.0;
  static const drawerHeaderFontSize = 36.0;
  static const drawerItemFontSize = 20.0;
}

// Navigation item model for better organization
class NavigationItem {
  final String titleKey;
  final Widget page;
  final IconData icon;

  const NavigationItem({
    required this.titleKey,
    required this.page,
    required this.icon,
  });
}

// Drawer item model
class DrawerMenuItem {
  final IconData icon;
  final String textKey;
  final VoidCallback onTap;

  const DrawerMenuItem({
    required this.icon,
    required this.textKey,
    required this.onTap,
  });
}

class BasePageLayout extends StatefulWidget {
  const BasePageLayout({super.key});

  @override
  State<BasePageLayout> createState() => _BasePageLayoutState();
}

class _BasePageLayoutState extends State<BasePageLayout>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Navigation items configuration
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      titleKey: 'home',
      page: HomeContent(),
      icon: Icons.home,
    ),
    NavigationItem(
      titleKey: 'settings',
      page: SettingContent(),
      icon: Icons.settings,
    ),
    NavigationItem(
      titleKey: 'help',
      page: HelpContent(),
      icon: Icons.help_outline_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Fade animation for page transitions
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Slide animation for drawer
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 250),
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
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    // Start initial animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _fadeController.reset();
      setState(() {
        _selectedIndex = index;
      });
      _fadeController.forward();
    }
  }

  Future<void> _navigateTo(BuildContext context, Widget page) async {
    Navigator.pop(context); // Close the drawer
    
    // Add a small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 150));
    
    if (mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final s = S.of(context)!;
    // Show confirmation dialog
    final shouldLogout = await _showLogoutDialog(context, s);
    if (shouldLogout && mounted) {
      Navigator.pop(context); // Close drawer
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LogIn(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  Future<bool> _showLogoutDialog(BuildContext context, S s) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(s.confirmLogout),
          content: Text(s.areYouSureLogout),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(s.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(s.logout),
            ),
          ],
        );
      },
    ) ?? false;
  }

  List<DrawerMenuItem> _getDrawerItems(BuildContext context) {
    final s = S.of(context)!;
    return [
      DrawerMenuItem(
        icon: Icons.verified_user_outlined,
        textKey: 'signatureVerification',
        onTap: () => _navigateTo(context, const Verification()),
      ),
      DrawerMenuItem(
        icon: Icons.history,
        textKey: 'history',
        onTap: () => _navigateTo(context, const HistoryPage()),
      ),
      DrawerMenuItem(
        icon: Icons.person_add_outlined,
        textKey: 'addAccount',
        onTap: () => _navigateTo(context, const SignUp()),
      ),
      DrawerMenuItem(
        icon: Icons.logout_outlined,
        textKey: 'logOut',
        onTap: () => _handleLogout(context),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.isDarkMode;
    final localeManager = Provider.of<LocaleManager>(context);
    final isArabic = localeManager.isArabic;
    final s = S.of(context)!;
    
    final currentItem = _navigationItems[_selectedIndex];
    final title = _getLocalizedTitle(s, currentItem.titleKey);
    
    return Scaffold(
      appBar: _buildAppBar(title, isDarkMode, isArabic),
      endDrawer: _buildDrawer(context, isDarkMode, s),
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey<int>(_selectedIndex),
            child: currentItem.page,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(  // Wrap navigation bar in SafeArea
        top: false,  // Prevent extra top padding
        child: _buildBottomNavigationBar(isDarkMode, s),
      ),
    );
  }

  String _getLocalizedTitle(S s, String key) {
    switch (key) {
      case 'home': return s.home;
      case 'settings': return s.settings;
      case 'help': return s.help;
      default: return key;
    }
  }

  PreferredSizeWidget _buildAppBar(String title, bool isDarkMode, bool isArabic) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Hero(
          tag: 'app_logo',
          child: Image.asset(
            'assets/images/logo3.png',
            width: 200,
            height: 60,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.account_balance,
                size: 32,
                color: isDarkMode ? Colors.white : AppConstants.primaryColor,
              );
            },
          ),
        ),
      ),
      centerTitle: true,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          title,
          key: ValueKey<String>(title),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      toolbarHeight: AppConstants.toolbarHeight,
      iconTheme: IconThemeData(
        color: isDarkMode ? Colors.white : Colors.grey,
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      elevation: 2,
      shadowColor: isDarkMode ? Colors.black : Colors.black26,
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDarkMode, S s) {
    final drawerItems = _getDrawerItems(context);
    
    return Drawer(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      child: Column(
        children: [
          _buildDrawerHeader(isDarkMode, s),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: drawerItems.length,
              itemBuilder: (context, index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeOutBack,
                  child: TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutBack,
                    builder: (context, animationValue, child) {
                      // Clamp the value to ensure it's within valid range
                      final clampedValue = animationValue.clamp(0.0, 1.0);
                      
                      return Transform.translate(
                        offset: Offset(50 * (1 - clampedValue), 0),
                        child: Opacity(
                          opacity: clampedValue,
                          child: _buildDrawerItem(
                            drawerItems[index], 
                            index, 
                            isDarkMode,
                            s
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          // Bottom decoration
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isDarkMode ? Colors.grey[900] : Colors.grey[50])!.withOpacity(0.0),
                  isDarkMode ? Colors.grey[900]! : Colors.grey[50]!,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(bool isDarkMode, S s) {
    final currentItem = _navigationItems[_selectedIndex];
    final title = _getLocalizedTitle(s, currentItem.titleKey);
    
    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
            ? [
                Colors.grey[850]!,
                Colors.grey[900]!,
              ]
            : [
                AppConstants.primaryColor,
                AppConstants.primaryColor.withOpacity(0.8),
              ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : AppConstants.primaryColor).withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Profile avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (isDarkMode ? Colors.white : Colors.white).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDarkMode ? Colors.white : Colors.white).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  currentItem.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              // Title with animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  title,
                  key: ValueKey<String>(title),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.welcomeBack,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    DrawerMenuItem item, 
    int index, 
    bool isDarkMode,
    S s
  ) {
    final text = _getLocalizedText(s, item.textKey);
    final isLogout = item.textKey == 'logOut';
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: isLogout 
              ? Colors.red.withOpacity(0.1)
              : AppConstants.primaryColor.withOpacity(0.1),
          highlightColor: isLogout 
              ? Colors.red.withOpacity(0.05)
              : AppConstants.primaryColor.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isLogout ? Colors.red : AppConstants.primaryColor)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: isLogout ? Colors.red : AppConstants.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isLogout 
                          ? Colors.red 
                          : (isDarkMode ? Colors.white : Colors.grey[800]),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedText(S s, String key) {
    switch (key) {
      case 'signatureVerification': return s.signatureVerification;
      case 'history': return s.history;
      case 'addAccount': return s.addAccount;
      case 'logOut': return s.logOut;
      default: return key;
    }
  }

  Widget _buildBottomNavigationBar(bool isDarkMode, S s) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _navigationItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = _selectedIndex == index;
            final title = _getLocalizedTitle(s, item.titleKey);
            
            return Expanded(
              child: GestureDetector(
                onTap: () => _onItemTapped(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon Container with animated background
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        width: isSelected ? 56 : 40,
                        height: isSelected ? 56 : 40,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppConstants.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(isSelected ? 16 : 12),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppConstants.primaryColor.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ] : null,
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected 
                              ? Colors.white 
                              : AppConstants.unselectedColor,
                          size: isSelected ? 24 : 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Animated label
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: isSelected ? 12 : 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected 
                              ? AppConstants.primaryColor 
                              : AppConstants.unselectedColor,
                        ),
                        child: Text(title),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}