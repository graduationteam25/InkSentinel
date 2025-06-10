import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inksentinel/generated/l10n.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../locale_manager.dart';
import '../../../theme_manager.dart';

/// History page displaying all signature verification results
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _listController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final List<Map<String, dynamic>> _filterOptions = [
    {'key': 'all', 'label': (s) => s.all},
    {'key': 'valid', 'label': (s) => s.valid},
    {'key': 'fake', 'label': (s) => s.fake},
  ];

  // State variables
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterStatusKey = 'all';
  // String _filterStatus = 'All'; // All, Valid, Fake
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimation();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _listController = AnimationController(
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
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startEntryAnimation() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _listController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Deletes a history entry with confirmation and animation
  Future<void> _deleteEntry(String docId, BuildContext context) async {
    final s = S.of(context)!;
    final bool confirmDelete = await _showDeleteDialog(context, s);
    if (!confirmDelete) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      await FirebaseFirestore.instance
          .collection('verification_results')
          .doc(docId)
          .delete();

      if (mounted) {
        _showSuccessSnackBar(s.entryDeleted);
      }
    } catch (e) {
      if (mounted) {
        _handleError(e, s.deleteFailed, context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Shows confirmation dialog with modern design
  Future<bool> _showDeleteDialog(BuildContext context, S s) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: AppColors.getWarningColor(context),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(s.confirmDeletion),
              ],
            ),
            content: Text(
              s.deleteConfirmation,
              style: const TextStyle(height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.getSubtitleColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  s.cancel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.getErrorColor(context),
                  backgroundColor: AppColors.getErrorColor(context).withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  s.delete,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.getErrorColor(context),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Handles and displays errors appropriately
  void _handleError(dynamic error, String defaultMessage, BuildContext context) {
    String errorMessage = defaultMessage;
    
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          errorMessage = S.of(context)!.permissionDenied;
          break;
        case 'not-found':
          errorMessage = S.of(context)!.entryNotFound;
          break;
        case 'unavailable':
          errorMessage = S.of(context)!.serviceUnavailable;
          break;
        default:
          errorMessage = error.message ?? defaultMessage;
      }
    }

    _showErrorSnackBar(errorMessage, context);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.getSuccessColor(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.getErrorColor(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Formats timestamp to readable date
  String _formatDate(dynamic timestamp, BuildContext context) {
    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return S.of(context)!.unknownDate;
      }
      
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      final s = S.of(context)!;
      
      if (difference == 0) {
        return '${s.today} ${DateFormat('HH:mm').format(date)}';
      } else if (difference == 1) {
        return '${s.yesterday} ${DateFormat('HH:mm').format(date)}';
      } else if (difference < 7) {
        return DateFormat('EEEE HH:mm').format(date);
      } else {
        return DateFormat('MMM dd, yyyy HH:mm').format(date);
      }
    } catch (e) {
      return S.of(context)!.invalidDate;
    }
  }

  /// Filters documents based on search and filter criteria
  bool _shouldShowDocument(Map<String, dynamic> data) {
    // Filter by status
    if (_filterStatusKey != 'all') {
    final result = (data['verification_result'] ?? data['result'] ?? '').toString().toLowerCase();
    final isValid = ['valid', 'genuine', 'authentic'].contains(result);
    
    if (_filterStatusKey == 'valid' && !isValid) return false;
    if (_filterStatusKey == 'fake' && isValid) return false;
  }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      final result = (data['verification_result'] ?? data['result'] ?? '').toString().toLowerCase();
      final date = _formatDate(data['timestamp'] ?? data['date'], context).toLowerCase();
      
      return result.contains(searchLower) || date.contains(searchLower);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.isDarkMode;
    final localeManager = Provider.of<LocaleManager>(context);
    final isArabic = localeManager.isArabic;
    final s = S.of(context)!;

    return Scaffold(
      appBar: _buildAppBar(s, isArabic),
      backgroundColor: AppColors.getBackground(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildSearchAndFilter(s, isDarkMode),
            Expanded(child: _buildHistoryList(s, isDarkMode)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(S s, bool isArabic) {
    return AppBar(
      title: Text(
        s.verificationHistory,
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFF259FA2),
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        icon: Icon(
          isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
          color: Colors.white,
          size: 22,
        ),
        tooltip: s.goBack,
      ),
      actions: [
        IconButton(
          onPressed: () => _showInfoDialog(s),
          icon: Icon(
            Icons.info_outline,
            color: Colors.white,
            size: 24,
          ),
          tooltip: s.information,
        ),
      ],
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  Widget _buildSearchAndFilter(S s, bool isDarkMode) {
    return Container(
      color: AppColors.getSurface(context),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            // textDirection: TextDirection.LTR, // Search always LTR
            decoration: InputDecoration(
              hintText: s.searchResults,
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      icon: Icon(Icons.clear, color: AppColors.getTextSecondary(context)),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getSubtitleColor(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: isDarkMode 
                  ? AppColors.getBackground(context).withOpacity(0.5)
                  : AppColors.getBackground(context),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 12),
          // Filter chips
          Row(
            children: [
              Text(
                '${s.filter}: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                    final isSelected = _filterStatusKey == filter['key'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter['label'](s)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _filterStatusKey = filter['key']);
                          },
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected 
                                ? AppColors.primary 
                                : AppColors.getTextSecondary(context),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(S s, bool isDarkMode) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('verification_results')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(s, isDarkMode);
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString(), s, isDarkMode);
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(s, isDarkMode);
        }

        final allDocs = snapshot.data!.docs;
        final filteredDocs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return _shouldShowDocument(data);
        }).toList();

        if (filteredDocs.isEmpty) {
          return _buildNoResultsState(s, isDarkMode);
        }

        return SlideTransition(
          position: _slideAnimation,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildHistoryItem(data, doc.id, index, s, isDarkMode);
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> data, String docId, int index, 
                           S s, bool isDarkMode) {
    final result = (data['verification_result'] ?? data['result'] ?? s.unknown).toString();
    final isValid = ['valid', 'genuine', 'authentic'].contains(result.toLowerCase());
    final timestamp = data['timestamp'] ?? data['date'];
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4,
        shadowColor: AppColors.getShadowColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showDetailsDialog(data, s, isDarkMode);
          },
          onLongPress: () => _deleteEntry(docId, context),
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildResultIcon(isValid, isDarkMode),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.signatureVerification,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(timestamp, context),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.getSubtitleColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildResultChip(result, isValid, isDarkMode),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteEntry(docId, context),
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.getErrorColor(context),
                    size: 24,
                  ),
                  tooltip: s.deleteEntry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultIcon(bool isValid, bool isDarkMode) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: (isValid 
            ? AppColors.getSuccessColor(context) 
            : AppColors.getErrorColor(context)).withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Icon(
        isValid ? Icons.check_circle : Icons.cancel,
        color: isValid 
            ? AppColors.getSuccessColor(context) 
            : AppColors.getErrorColor(context),
        size: 28,
      ),
    );
  }

  Widget _buildResultChip(String result, bool isValid, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isValid 
            ? AppColors.getSuccessColor(context) 
            : AppColors.getErrorColor(context)).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isValid 
            ? AppColors.getSuccessColor(context) 
            : AppColors.getErrorColor(context)).withOpacity(0.3),
        ),
      ),
      child: Text(
        result.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isValid 
            ? AppColors.getSuccessColor(context) 
            : AppColors.getErrorColor(context),
        ),
      ),
    );
  }

  Widget _buildLoadingState(S s, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            s.loadingHistory,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getSubtitleColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(S s, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.getSubtitleColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            s.noHistory,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.historyWillAppear,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getSubtitleColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(S s, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.getSubtitleColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            s.noResults,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.adjustSearch,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getSubtitleColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, S s, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.getErrorColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            s.errorLoading,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.tryAgainLater,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.getSubtitleColor(context),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Trigger rebuild
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              s.retry,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(Map<String, dynamic> data, S s, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(s.verificationDetails),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(s.result, data['verification_result'] ?? data['result'] ?? s.unknown, s),
            _buildDetailRow(s.date, _formatDate(data['timestamp'] ?? data['date'], context), s),
            if (data['device_info'] != null) ...[
              _buildDetailRow(s.platform, data['device_info']['platform'] ?? s.unknown, s),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, S s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(S s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(s.aboutHistory),
          ],
        ),
        content: Text(
          s.historyPageInfo,
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.gotIt),
          ),
        ],
      ),
    );
  }
}