import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'selected_original.dart';
import '../../../generated/l10n.dart';
import '../../../theme_manager.dart';

class ScanTestd extends StatefulWidget {
  final String select;
  const ScanTestd(this.select, {super.key});

  @override
  State<ScanTestd> createState() => _ScanTestdState();
}

class _ScanTestdState extends State<ScanTestd>
    with TickerProviderStateMixin {
  final ImagePicker _imagePicker = ImagePicker();
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
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
    
    setState(() => _isProcessing = true);

    try {
      final XFile? xFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (xFile == null) {
        _showCustomSnackBar(S.of(context).noImageSelected, AppColors.getWarningColor(context));
        setState(() => _isProcessing = false);
        return;
      }

      _showCustomSnackBar(S.of(context).processingImage, AppColors.primary);

      final File savedImage = await _saveImageLocally(File(xFile.path));

      if (!mounted) return;
      await _closeModalWithAnimation();

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SelectedOriginalScreen(
                imageFile: savedImage,
                imagePath: savedImage.path,
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
      _showCustomSnackBar('${S.of(context).error}: $e', AppColors.getErrorColor(context));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<File> _saveImageLocally(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'signature_${widget.select}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return image.copy('${directory.path}/$fileName');
  }

  void _showCustomSnackBar(String message, Color color) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == AppColors.getErrorColor(context) 
                ? Icons.error_outline 
                : color == AppColors.getWarningColor(context) 
                  ? Icons.warning_outlined 
                  : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: Duration(seconds: color == AppColors.primary ? 1 : 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _closeModalWithAnimation() async {
    await _scaleController.reverse();
    await _slideController.reverse();
    await _fadeController.reverse();
    if (mounted) Navigator.pop(context);
  }

  void _handleCancel() async => await _closeModalWithAnimation();

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 400;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(isDarkMode),
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildContent(isMobile, isDarkMode),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).chooseImageSource,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).selectSourceDescription,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        children: [
          _buildOptionCard(
            icon: Icons.photo_library_outlined,
            title: S.of(context).chooseFromGallery,
            subtitle: S.of(context).galleryDescription,
            onTap: () => _pickImage(ImageSource.gallery),
            color: const Color(0xFF4285F4),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            icon: Icons.camera_alt_outlined,
            title: S.of(context).takePhoto,
            subtitle: S.of(context).cameraDescription,
            onTap: () => _pickImage(ImageSource.camera),
            color: const Color(0xFF34A853),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 20),
          _buildCancelButton(isMobile, isDarkMode),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isProcessing ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode 
              ? Colors.grey[800]!.withOpacity(0.3)
              : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode 
                ? Colors.grey[700]!
                : color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode 
                    ? Colors.grey[700]!
                    : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
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
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.getTextSecondary(context),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(bool isMobile, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 50 : 56,
      child: TextButton(
        onPressed: _isProcessing ? null : _handleCancel,
        style: TextButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
          foregroundColor: AppColors.getTextSecondary(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          S.of(context).cancel,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}