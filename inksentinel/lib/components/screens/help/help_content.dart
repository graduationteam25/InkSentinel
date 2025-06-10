import 'package:flutter/material.dart';
import 'package:inksentinel/generated/l10n.dart';
import 'package:provider/provider.dart';

import '../../../locale_manager.dart';
import '../../../theme_manager.dart';
import 'ChatbotPage.dart';

/// Enhanced Help page with responsive design and smooth animations
class HelpContent extends StatefulWidget {
  const HelpContent({super.key});

  @override
  State<HelpContent> createState() => _HelpContentState();
}

class _HelpContentState extends State<HelpContent>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _itemsController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _itemsAnimation;

  // State management
  final Map<int, bool> _expandedStates = {};
  final Map<int, AnimationController> _expansionControllers = {};
  final Map<int, Animation<double>> _expansionAnimations = {};

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initExpansionAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Fade animation for overall content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

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
    _itemsAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _itemsController, curve: Curves.easeOutBack));
  }

  void _initExpansionAnimations() {
    for (int i = 0; i < questions(S.current).length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _expansionControllers[i] = controller;
      _expansionAnimations[i] = Tween<double>(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    }
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _itemsController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _itemsController.dispose();
    
    // Dispose expansion controllers
    for (final controller in _expansionControllers.values) {
      controller.dispose();
    }
    
    super.dispose();
  }

  void _toggleExpansion(int index) {
    final isExpanded = _expandedStates[index] ?? false;
    final controller = _expansionControllers[index]!;
    
    setState(() {
      _expandedStates[index] = !isExpanded;
    });

    if (_expandedStates[index]!) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final localeManager = Provider.of<LocaleManager>(context);
    final isDarkMode = themeManager.isDarkMode;
    final isArabic = localeManager.isArabic;
    final strings = S.of(context)!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildResponsiveContent(context, constraints, isDarkMode, isArabic, strings);
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveContent(
    BuildContext context, 
    BoxConstraints constraints, 
    bool isDarkMode,
    bool isArabic,
    S strings,
    ) {
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
            child: _buildHeader(isMobile, isDarkMode, isArabic, strings),
          ),
          const SizedBox(height: 24),
          _buildFAQSection(isMobile, isDarkMode, isArabic, strings),
        ],
      ),
    );
  }

  Widget _buildHeader(
    bool isMobile, 
    bool isDarkMode,
    bool isArabic,
    S strings,
    ) {
    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.helpSupportTitle,
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.getTextPrimary(context),
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.faqSubtitle,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: AppColors.getSubtitleColor(context),
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(isDarkMode ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: isMobile ? 20 : 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  strings.tapInstruction,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: AppColors.getTextPrimary(context),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAQSection(
    bool isMobile, 
    bool isDarkMode,
    bool isArabic,
    S strings,
  ) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          ..._buildAnimatedFAQItems(questions(strings), isMobile, isDarkMode, isArabic),
          const SizedBox(height: 20),
          _buildActionButtons(isMobile, isDarkMode, isArabic, strings),
        ],
      ),
    );
  }
  

  List<Widget> _buildAnimatedFAQItems(
    List<HelpQuestion> questions, 
    bool isMobile, 
    bool isDarkMode,
    bool isArabic,
  ) {
    return questions.asMap().entries.map((entry) {
      final index = entry.key;
      final qa = entry.value;
      
      return AnimatedBuilder(
        animation: _itemsAnimation,
        builder: (context, child) {
          // Calculate delay for staggered animation
          final delay = index * 0.1;
          final adjustedValue = (_itemsAnimation.value - delay).clamp(0.0, 1.0);
          final animationValue = Curves.easeOutBack.transform(adjustedValue);
          
          // Ensure values are properly clamped
          final opacity = animationValue.clamp(0.0, 1.0);
          final translateY = 30.0 * (1.0 - animationValue).clamp(0.0, 1.0);
          
          return Transform.translate(
            offset: Offset(0, translateY),
            child: Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFAQItem(qa, index, isMobile, isDarkMode, isArabic),
              ),
            ),
          );
        },
      );
    }).toList();
  }

   Widget _buildFAQItem(
    HelpQuestion qa, 
    int index, 
    bool isMobile, 
    bool isDarkMode,
    bool isArabic,
  ) {
    final isExpanded = _expandedStates[index] ?? false;
    final expansionAnimation = _expansionAnimations[index]!;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleExpansion(index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildQuestionHeader(qa, isExpanded, isMobile, isArabic),
                AnimatedBuilder(
                  animation: expansionAnimation,
                  builder: (context, child) {
                    return SizeTransition(
                      sizeFactor: expansionAnimation,
                      axisAlignment: -1.0,
                      child: FadeTransition(
                        opacity: expansionAnimation,
                        child: _buildAnswerSection(qa, isMobile, isArabic),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

   Widget _buildQuestionHeader(
    HelpQuestion qa, 
    bool isExpanded, 
    bool isMobile,
    bool isArabic,
  ) {
    return Row(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.quiz_outlined,
            color: AppColors.primary,
            size: isMobile ? 18 : 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            qa.text,
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
          ),
        ),
        AnimatedRotation(
          turns: isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerSection(
    HelpQuestion qa, 
    bool isMobile,
    bool isArabic,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getAnswerBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              qa.answers,
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: isMobile ? 14 : 16,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    bool isMobile, 
    bool isDarkMode,
    bool isArabic,
    S strings,
  ) {
    return Column(
      children: [
        // Chatbot Button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C5CE7),
                const Color(0xFFA29BFE),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C5CE7).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: isMobile ? 32 : 40,
              ),
              const SizedBox(height: 12),
              Text(
                strings.chatWithAI ?? 'Chat with AI Assistant',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.chatbotDescription ?? 'Learn more about our app and get instant answers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatbotPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6C5CE7),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chat_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      strings.startChat ?? 'Start Chat',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Contact Support Button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF15B7BA),
                const Color(0xFF1B225B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF15B7BA).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: isMobile ? 32 : 40,
              ),
              const SizedBox(height: 12),
              Text(
                strings.stillNeedHelp,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.contactSupportPrompt,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _showContactDialog(isArabic, strings);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1B225B),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      strings.contactSupport,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showContactDialog(bool isArabic, S strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Icon(
              Icons.support_agent_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(strings.contactSupport),
          ],
        ),
        content: Text(
          strings.contactSupportDetails,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.close),
          ),
        ],
      ),
    );
  }
}

// Data models for better organization
class HelpQuestion {
  const HelpQuestion(this.text, this.answers);
  final String text;
  final String answers;
}

List<HelpQuestion> questions(S strings) {
  return [
    HelpQuestion(strings.question1, strings.answer1),
    HelpQuestion(strings.question2, strings.answer2),
    HelpQuestion(strings.question3, strings.answer3),
    HelpQuestion(strings.question4, strings.answer4),
    HelpQuestion(strings.question5, strings.answer5),
    HelpQuestion(strings.question6, strings.answer6),
  ];
}