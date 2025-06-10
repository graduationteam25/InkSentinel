import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inksentinel/generated/l10n.dart';
import 'package:provider/provider.dart';

import '../../../locale_manager.dart';
import '../../../theme_manager.dart';

/// Chatbot page integrated with the Ink Sentinel API
class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _itemsController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _itemsAnimation;

  // Chat state
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  // API configuration
  static const String _apiBaseUrl = 'http://192.168.1.8:5000'; // Adjust as needed
  static const String _chatEndpoint = '/api/chat';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      _addWelcomeMessage();
    }
  }

  void _initAnimations() {
    // Fade animation for overall content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    // Items staggered animation
    _itemsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _itemsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _itemsController, curve: Curves.easeOutBack),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _itemsController.forward();
  }

  void _addWelcomeMessage() {
    final strings = S.of(context);
    _messages.add(ChatMessage(
      text: strings?.chatbotWelcome ??
          "Hello! I'm Ink Sentinel, your intelligent signature verification assistant. How may I assist you today? Do you have a signature that needs verification?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
    setState(() {});
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _itemsController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final response = await _generateResponse(userMessage);
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Error: Failed to get response from the server. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  Future<String> _generateResponse(String message) async {
    final localeManager = Provider.of<LocaleManager>(context, listen: false);
    final language = localeManager.isArabic ? 'Arabic' : 'English';

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl$_chatEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['response'] != null) {
          return data['response'];
        } else {
          throw Exception('Invalid response from server: ${data['message']}');
        }
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to communicate with server: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final localeManager = Provider.of<LocaleManager>(context);
    final isDarkMode = themeManager.isDarkMode;
    final isArabic = localeManager.isArabic;
    final strings = S.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.chatbotTitle ?? 'Ink Sentinel',
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.getSurface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.getTextPrimary(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: _buildHeader(context, isDarkMode, isArabic, strings),
            ),
            Expanded(
              child: _buildChatArea(context, isDarkMode, isArabic, strings),
            ),
            _buildMessageInput(context, isDarkMode, isArabic, strings),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode, bool isArabic, S strings) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C5CE7),
                  const Color(0xFFA29BFE),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  strings.aiAssistant ?? 'Ink Sentinel',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(context),
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
                Text(
                  strings.onlineStatus ?? 'Online • Ready to help',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF00D4AA),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(BuildContext context, bool isDarkMode, bool isArabic, S strings) {
    return Container(
      color: AppColors.getBackground(context),
      child: AnimatedBuilder(
        animation: _itemsAnimation,
        builder: (context, child) {
          return ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isTyping) {
                return _buildTypingIndicator(isArabic);
              }

              final message = _messages[index];
              final animationValue = _itemsAnimation.value;
              final opacity = animationValue.clamp(0.0, 1.0);

              return Opacity(
                opacity: opacity,
                child: _buildMessageBubble(message, isArabic),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isArabic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser
            ? (isArabic ? MainAxisAlignment.start : MainAxisAlignment.end)
            : (isArabic ? MainAxisAlignment.end : MainAxisAlignment.start),
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C5CE7),
                    const Color(0xFFA29BFE),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : AppColors.getSurface(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getShadowColor(context),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : AppColors.getTextPrimary(context),
                      fontSize: 16,
                      height: 1.4,
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.getTextSecondary(context),
                      fontSize: 12,
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isArabic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C5CE7),
                  const Color(0xFFA29BFE),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadowColor(context),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.3 + (0.7 * value)),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(BuildContext context, bool isDarkMode, bool isArabic, S strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.getBackground(context),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: TextField(
                controller: _messageController,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: strings.typeMessage ?? 'Type your message...',
                  hintStyle: TextStyle(
                    color: AppColors.getTextSecondary(context),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C5CE7),
                  const Color(0xFFA29BFE),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _sendMessage,
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    isArabic ? Icons.send_rounded : Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}