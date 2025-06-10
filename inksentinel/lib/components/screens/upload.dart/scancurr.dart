import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart';
import '../Upload Current Images/check_verification.dart';
import '../../../variable.dart';
import '../../../theme_manager.dart'; // Added for theme
import '../../../locale_manager.dart'; // Added for localization

/// Enhanced current signature picker modal with dark mode and localization
class Scancurr extends StatefulWidget {
  final String originalImagePath;
  final File imageFile;
  
  const Scancurr({
    super.key, 
    required this.originalImagePath, 
    required this.imageFile,
  });

  @override
  State<Scancurr> createState() => _ScancurrState();
}

class _ScancurrState extends State<Scancurr>
    with TickerProviderStateMixin {
  
  final ImagePicker _imagePicker = ImagePicker();
  
  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  
  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Loading state
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));
  }

  void _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile? xFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (xFile == null) {
        _showCustomSnackBar(S.of(context).noImageSelected, AppColors.getWarningColor(context));
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Show processing indicator
      _showCustomSnackBar(S.of(context).processingCurrentSignature, AppColors.primary);

      // Convert XFile to File and save locally
      final File savedCurrentImage = await _saveImageLocally(File(xFile.path));

      if (!mounted) return;

      // Close modal with animation
      await _closeModalWithAnimation();

      // Navigate to verification page with both images
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              Selectedcurr(
                currentImageFile: savedCurrentImage,
                originalImageFile: widget.imageFile,
              ),
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
    } catch (e) {
      _showCustomSnackBar('${S.of(context).error}: ${e.toString()}', AppColors.getErrorColor(context));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<File> _saveImageLocally(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileName = 'signature_current_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = "${directory.path}/$fileName";
    return await image.copy(newPath);
  }

  void _showCustomSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                color == AppColors.getErrorColor(context) ? Icons.error_outline : 
                color == AppColors.getWarningColor(context) ? Icons.warning_outlined : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          duration: Duration(seconds: color == AppColors.primary ? 1 : 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _closeModalWithAnimation() async {
    await _scaleController.reverse();
    await _slideController.reverse();
    await _fadeController.reverse();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _handleCancel() async {
    await _closeModalWithAnimation();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    final localeManager = context.watch<LocaleManager>();
    final isDarkMode = themeManager.isDarkMode;
    final strings = S.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 400;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.getSurface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(strings, isDarkMode),
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildContent(strings, isMobile, isDarkMode),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(S strings, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            strings.uploadCurrentSignature,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.uploadCurrentSignatureDescription,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getSubtitleColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(S strings, bool isMobile, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(strings, isDarkMode),
          const SizedBox(height: 24),
          
          _buildOptionCard(
            icon: Icons.photo_library_outlined,
            title: strings.chooseFromGallery,
            subtitle: strings.galleryDescription,
            onTap: () => _pickImage(ImageSource.gallery),
            color: const Color(0xFF4285F4),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            icon: Icons.camera_alt_outlined,
            title: strings.takePhoto,
            subtitle: strings.cameraDescription,
            onTap: () => _pickImage(ImageSource.camera),
            color: const Color(0xFF34A853),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 20),
          _buildCancelButton(strings, isMobile, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(S strings, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            strings.originalSignatureUploaded, // New translation key
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "2/2",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    required bool isDarkMode,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isProcessing ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.getSubtitleColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isProcessing)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.getSubtitleColor(context),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(S strings, bool isMobile, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 50 : 56,
      child: TextButton(
        onPressed: _isProcessing ? null : _handleCancel,
        style: TextButton.styleFrom(
          backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
          foregroundColor: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          strings.cancel,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}