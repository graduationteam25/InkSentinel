import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Upload Current Images/verification_current.dart';
import 'scan.dart';
import '../../../generated/l10n.dart';
import '../../../theme_manager.dart';

class SelectedOriginalScreen extends StatefulWidget {
  final String imagePath;
  final File imageFile;

  const SelectedOriginalScreen({
    required this.imageFile,
    required this.imagePath,
    super.key,
  });

  @override
  State<SelectedOriginalScreen> createState() => _SelectedOriginalScreenState();
}

class _SelectedOriginalScreenState extends State<SelectedOriginalScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadImageWithAnimation();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

  Future<void> _loadImageWithAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _imageLoaded = true);
      _fadeController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _slideController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleImageChange() async {
    try {
      HapticFeedback.lightImpact();
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) => _buildBottomSheet(),
      );
    } catch (e) {
      _showErrorSnackbar(S.of(context).failedToOpenSelector);
    }
  }

  Widget _buildBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12.0),
        ),
      ),
      child: const Wrap(
        children: [ScanTestd('original')],
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_isLoading) return;

    try {
      setState(() => _isLoading = true);
      HapticFeedback.selectionClick();

      if (!await widget.imageFile.exists()) {
        throw Exception(S.of(context).imageFileNotFound);
      }

      if (!mounted) return;

      await Navigator.push<void>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              VerificationCurrent(
            originalImagePath: widget.imagePath,
            imageFile: widget.imageFile,
          ),
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
    } catch (e) {
      _showErrorSnackbar(S.of(context).failedToProceed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.getErrorColor(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.isDarkMode;
    
    return Scaffold(
      appBar: _buildAppBar(isDarkMode),
      backgroundColor: AppColors.getBackground(context),
      body: _buildBody(isDarkMode),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      title: Text(
        S.of(context).uploadImages,
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 22,
        ),
        tooltip: S.of(context).goBack,
      ),
      systemOverlayStyle: isDarkMode 
          ? SystemUiOverlayStyle.light 
          : SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildBody(bool isDarkMode) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20.0),
              _buildImageContainer(isDarkMode),
              const SizedBox(height: 20.0),
              _buildChangeImageButton(),
              const SizedBox(height: 30.0),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      S.of(context).uploadOriginalSignatureTitle,
      style: TextStyle(
        color: AppColors.getTextPrimary(context),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildImageContainer(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                ? Colors.black.withOpacity(0.4) 
                : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: _imageLoaded
              ? Image.file(
                  widget.imageFile,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImageError(isDarkMode),
                )
              : _buildImagePlaceholder(isDarkMode),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDarkMode) {
    return Container(
      color: isDarkMode 
        ? Colors.grey.shade800 
        : Colors.grey.shade200,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildImageError(bool isDarkMode) {
    return Container(
      color: isDarkMode 
        ? Colors.grey.shade900 
        : Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: isDarkMode 
              ? Colors.grey.shade400 
              : Colors.grey.shade600,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).failedToLoadImage,
            style: TextStyle(
              color: isDarkMode 
                ? Colors.grey.shade400 
                : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeImageButton() {
    return AnimatedScale(
      scale: _imageLoaded ? 1.0 : 0.8,
      duration: const Duration(milliseconds: 300),
      child: TextButton.icon(
        onPressed: _handleImageChange,
        icon: Icon(
          Icons.refresh_rounded,
          color: AppColors.primary,
          size: 24,
        ),
        label: Text(
          S.of(context).changeImage,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                S.of(context).next,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}