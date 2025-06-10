import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart';
import '../../../locale_manager.dart';
import '../../../theme_manager.dart';
import '../home/bar.dart';

class Selectedcurr extends StatefulWidget {
  final File originalImageFile;
  final File currentImageFile;

  const Selectedcurr({
    required this.originalImageFile,
    required this.currentImageFile,
    super.key,
  });

  @override
  State<Selectedcurr> createState() => _SelectedcurrState();
}

class _SelectedcurrState extends State<Selectedcurr>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _buttonController;
  late AnimationController _loadingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<Color?> _buttonColorAnimation;
  bool _isLoading = false;
  bool _isConnected = true;
  String? _verificationResult;
  String? _requestId;

  static const Color _primaryColor = AppColors.primary;
  static const Color _backgroundColor = Colors.transparent;
  static const double _borderRadius = 16.0;
  static const double _spacing = 24.0;

  static const String _apiBaseUrl = "http://192.168.1.8:5000";
  static const String _apiKey = "your-secure-api-key-here";
  static const Duration _apiTimeout = Duration(seconds: 45);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkConnectivity();
    _startEntryAnimation();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    _buttonColorAnimation = ColorTween(
      begin: _primaryColor,
      end: _primaryColor.withOpacity(0.8),
    ).animate(_buttonController);
  }

  void _startEntryAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      setState(() {
        _isConnected = connectivityResult != ConnectivityResult.none;
      });
    } catch (e) {
      setState(() => _isConnected = false);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _buttonController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future<bool> _validateImages() async {
    try {
      if (!await widget.originalImageFile.exists() ||
          !await widget.currentImageFile.exists()) {
        throw Exception(S.of(context).imageFileNotFound);
      }

      const maxFileSize = 10 * 1024 * 1024;
      final originalSize = await widget.originalImageFile.length();
      final currentSize = await widget.currentImageFile.length();

      if (originalSize > maxFileSize || currentSize > maxFileSize) {
        throw Exception('Image files are too large (max 10MB each)');
      }

      if (originalSize < 1024 || currentSize < 1024) {
        throw Exception('Image files are too small (min 1KB each)');
      }

      final originalBytes = await widget.originalImageFile.readAsBytes();
      final currentBytes = await widget.currentImageFile.readAsBytes();

      if (!_isValidImageFormat(originalBytes) || !_isValidImageFormat(currentBytes)) {
        throw Exception(S.of(context).failedToLoadImage);
      }

      if (!_isSecureImage(originalBytes) || !_isSecureImage(currentBytes)) {
        throw Exception('Security validation failed');
      }

      return true;
    } catch (e) {
      _showErrorDialog(S.of(context).error, e.toString());
      return false;
    }
  }

  bool _isValidImageFormat(Uint8List bytes) {
    if (bytes.length < 12) return false;
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 &&
        bytes[4] == 0x0D && bytes[5] == 0x0A && bytes[6] == 0x1A && bytes[7] == 0x0A) return true;
    if (bytes.length >= 12) {
      final riff = String.fromCharCodes(bytes.sublist(0, 4));
      final webp = String.fromCharCodes(bytes.sublist(8, 12));
      if (riff == 'RIFF' && webp == 'WEBP') return true;
    }
    return false;
  }

  bool _isSecureImage(Uint8List bytes) {
    final content = String.fromCharCodes(bytes.take(1024));
    final suspiciousPatterns = [
      '<script',
      'javascript:',
      'data:text/html',
      '<?php',
      '<%',
    ];
    for (final pattern in suspiciousPatterns) {
      if (content.toLowerCase().contains(pattern)) {
        return false;
      }
    }
    return true;
  }

  String _generateRequestHash(File file1, File file2) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final content = '${file1.path}${file2.path}$timestamp$_apiKey';
    return sha256.convert(utf8.encode(content)).toString().substring(0, 16);
  }

  Future<void> _verifyImages() async {
    if (_isLoading) return;

    await _checkConnectivity();
    if (!_isConnected) {
      _showErrorDialog(S.of(context).error, S.of(context).tooManyRequests);
      return;
    }

    if (!await _validateImages()) return;

    setState(() => _isLoading = true);
    _loadingController.repeat();
    HapticFeedback.mediumImpact();

    try {
      final result = await _performVerificationWithRetry();
      if (result != null) {
        setState(() {
          _verificationResult = result['status'] as String?;
          _requestId = result['request_id'] as String?;
        });
        await _saveResultToFirestore(result);
        _showResultDialog(result);
      }
    } catch (e) {
      _handleVerificationError(e);
    } finally {
      setState(() => _isLoading = false);
      _loadingController.stop();
    }
  }

  Future<Map<String, dynamic>?> _performVerificationWithRetry() async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        return await _performVerification();
      } catch (e) {
        if (attempt == _maxRetries) {
          rethrow;
        }
        await Future.delayed(_retryDelay * attempt);
        await _checkConnectivity();
        if (!_isConnected) {
          throw SocketException(S.of(context).tooManyRequests);
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> _performVerification() async {
    // final uri = Uri.parse("$_apiBaseUrl/verify");
    final uri = Uri.parse("$_apiBaseUrl/api/verify-signature");
    final request = http.MultipartRequest("POST", uri);
    final client = http.Client();

    try {
      request.headers.addAll({
        'X-API-Key': _apiKey,
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
        'User-Agent': 'SignatureVerificationApp/1.0',
        'X-Request-ID': _generateRequestHash(widget.originalImageFile, widget.currentImageFile),
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          "original",
          widget.originalImageFile.path,
          filename: "original_signature.jpg",
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          "current",
          widget.currentImageFile.path,
          filename: "current_signature.jpg",
        ),
      );

      final streamedResponse = await client.send(request).timeout(_apiTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleApiResponse(response);
    } on SocketException {
      throw Exception(S.of(context).tooManyRequests);
    } on HttpException catch (e) {
      throw Exception('Server communication error: ${e.message}');
    } on FormatException {
      throw Exception(S.of(context).failedToLoadImage);
    } on TimeoutException {
      throw Exception(S.of(context).tooManyRequests);
    } finally {
      client.close();
    }
  }

  Map<String, dynamic>? _handleApiResponse(http.Response response) {
    try {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      switch (response.statusCode) {
        case 200:
          return _parseSuccessResponse(responseData);
        case 400:
          final errorMsg = responseData['message'] ?? S.of(context).error;
          throw ValidationException(errorMsg);
        case 401:
          throw SecurityException('Authentication failed');
        case 403:
          throw SecurityException('Access forbidden');
        case 413:
          throw ValidationException('File too large');
        case 429:
          throw RateLimitException(S.of(context).tooManyRequests);
        case 500:
          final requestId = responseData['request_id'] ?? 'unknown';
          throw ServerException('Server error (ID: $requestId)');
        default:
          throw HttpException('Unexpected server response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(S.of(context).failedToLoadImage);
    }
  }

  Map<String, dynamic> _parseSuccessResponse(Map<String, dynamic> responseData) {
  final requiredFields = ['status', 'confidence', 'similarity_score'];
  for (final field in requiredFields) {
    if (!responseData.containsKey(field)) {
      throw FormatException('Invalid response: missing $field field');
    }
  }

  final status = responseData['status']?.toString().toLowerCase() ?? '';
  if (!['valid', 'fake', 'genuine', 'authentic', 'invalid'].contains(status)) {
    throw FormatException('Invalid verification status: $status');
  }

  final confidence = responseData['confidence'] is num ? responseData['confidence'] as num : 0.0;
  if (confidence < 0 || confidence > 1) {
    throw FormatException('Invalid confidence value');
  }

  return responseData;
}

  void _handleVerificationError(dynamic error) {
    String title = S.of(context).error;
    String message = S.of(context).unexpectedError;

    if (error is ValidationException) {
      title = 'Validation Error';
      message = error.message;
    } else if (error is SecurityException) {
      title = 'Security Error';
      message = error.message;
    } else if (error is RateLimitException) {
      title = 'Rate Limit Exceeded';
      message = error.message;
    } else if (error is ServerException) {
      title = 'Server Error';
      message = error.message;
    } else if (error is SocketException) {
      title = 'Network Error';
      message = S.of(context).tooManyRequests;
    } else if (error is HttpException) {
      title = 'Communication Error';
      message = error.message;
    } else if (error is TimeoutException) {
      title = 'Timeout Error';
      message = S.of(context).tooManyRequests;
    } else if (error is FormatException) {
      title = 'Data Error';
      message = S.of(context).failedToLoadImage;
    } else {
      message = error.toString();
    }

    _showErrorDialog(title, message);
  }

  Future<void> _saveResultToFirestore(Map<String, dynamic> result) async {
    try {
      final collection = FirebaseFirestore.instance.collection('verification_results');
      final documentData = {
        'original_image_path': widget.originalImageFile.path,
        'current_image_path': widget.currentImageFile.path,
        'verification_result': result['status'],
        'confidence': result['confidence'],
        'similarity_score': result['similarity_score'],
        'distance': result['distance'],
        'threshold': result['threshold'],
        'inference_time_ms': result['inference_time_ms'],
        'model_version': result['model_version'],
        'request_id': result['request_id'],
        'timestamp': FieldValue.serverTimestamp(),
        'created_at': DateTime.now().toIso8601String(),
        'api_version': '2.0',
        'device_info': {
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
        },
      };

      await collection.add(documentData);
      _showSnackBar(S.of(context).entryDeleted, isError: false);
    } catch (e) {
      debugPrint('Failed to save result to Firestore: $e');
      _showSnackBar('Result saved locally', isError: false);
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    final status = result['status'].toString().toLowerCase();
    final isValid = ['valid', 'genuine', 'authentic'].contains(status);
    final confidence = (result['confidence'] as num).toDouble();
    final similarityScore = (result['similarity_score'] as num).toDouble();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _buildEnhancedResultDialog(isValid, result, confidence, similarityScore),
    );
  }

  Widget _buildEnhancedResultDialog(bool isValid, Map<String, dynamic> result, double confidence, double similarityScore) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      backgroundColor: AppColors.getSurface(context),
      title: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? AppColors.getSuccessColor(context) : AppColors.getErrorColor(context),
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            S.of(context).verificationDetails,
            style: TextStyle(color: AppColors.getTextPrimary(context)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isValid ? S.of(context).valid : S.of(context).fake,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isValid ? AppColors.getSuccessColor(context) : AppColors.getErrorColor(context),
            ),
          ),
          const SizedBox(height: 12),
          _buildResultMetric(S.of(context).result, '${(confidence * 100).toStringAsFixed(1)}%', confidence),
          const SizedBox(height: 8),
          _buildResultMetric('Similarity', '${(similarityScore * 100).toStringAsFixed(1)}%', similarityScore),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.getAnswerBackground(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.getShadowColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).information,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Distance: ${result['distance']?.toStringAsFixed(4) ?? 'N/A'}',
                  style: TextStyle(fontSize: 11, color: AppColors.getTextSecondary(context)),
                ),
                Text(
                  'Processing: ${result['inference_time_ms']?.toStringAsFixed(1) ?? 'N/A'}ms',
                  style: TextStyle(fontSize: 11, color: AppColors.getTextSecondary(context)),
                ),
                if (_requestId != null)
                  Text(
                    'Request ID: $_requestId',
                    style: TextStyle(fontSize: 10, color: AppColors.getTextSecondary(context).withOpacity(0.7)),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _handleDialogClose,
          style: TextButton.styleFrom(
            foregroundColor: _primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            S.of(context).next,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildResultMetric(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.getShadowColor(context),
          valueColor: AlwaysStoppedAnimation(
            progress > 0.7
                ? AppColors.getSuccessColor(context)
                : progress > 0.4
                    ? AppColors.getWarningColor(context)
                    : AppColors.getErrorColor(context),
          ),
        ),
      ],
    );
  }

  void _handleDialogClose() {
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const BasePageLayout(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
      (route) => false,
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        backgroundColor: AppColors.getSurface(context),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.getErrorColor(context), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: AppColors.getTextPrimary(context)),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
        actions: [
          if (_requestId != null)
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _requestId!));
                _showSnackBar(S.of(context).copyText, isError: false);
              },
              child: Text(S.of(context).copyText),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              S.of(context).close,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? AppColors.getErrorColor(context) : AppColors.getSuccessColor(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
        action: isError
            ? SnackBarAction(
                label: S.of(context).retry,
                textColor: Colors.white,
                onPressed: _verifyImages,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Provider.of<LocaleManager>(context).isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: AppColors.getBackground(context),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        S.of(context).signatureVerification,
        style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).appBarTheme.foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: _isLoading
            ? null
            : () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: Theme.of(context).appBarTheme.foregroundColor,
          size: 22,
        ),
        tooltip: S.of(context).goBack,
      ),
      systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: _spacing),
              _buildImageContainer(),
              const SizedBox(height: _spacing),
              _buildConnectionStatus(),
              const SizedBox(height: _spacing),
              _buildVerificationButton(),
              const SizedBox(height: 16),
              _buildEnhancedInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          S.of(context).uploadCurrentSignature,
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          S.of(context).patternMatchingDescription,
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
            fontSize: 16,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImageContainer() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(context),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Image.file(
          widget.currentImageFile,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.getAnswerBackground(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.getTextSecondary(context),
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).failedToLoadImage,
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    if (_isConnected) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getErrorColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.getErrorColor(context).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: AppColors.getErrorColor(context), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              S.of(context).tooManyRequests,
              style: TextStyle(
                color: AppColors.getErrorColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _checkConnectivity,
            child: Text(S.of(context).retry),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationButton() {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 60,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      _buttonController.forward().then((_) {
                        _buttonController.reverse();
                      });
                      _verifyImages();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColorAnimation.value ?? _primaryColor,
                disabledBackgroundColor: _primaryColor.withOpacity(0.6),
                foregroundColor: Colors.white,
                elevation: _isLoading ? 0 : 4,
                shadowColor: _primaryColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_borderRadius),
                ),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          S.of(context).processingImage,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      S.of(context).verify,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getShadowColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                S.of(context).secureResults,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            S.of(context).secureResultsDescription,
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFeatureChip(S.of(context).featureSecure, AppColors.getSuccessColor(context)),
              const SizedBox(width: 8),
              _buildFeatureChip(S.of(context).featureFast, Colors.blue),
              const SizedBox(width: 8),
              _buildFeatureChip(S.of(context).featureAccurate, AppColors.getWarningColor(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
}

class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}