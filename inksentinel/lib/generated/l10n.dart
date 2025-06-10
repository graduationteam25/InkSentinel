// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Make sure your signatures are correct.`
  String get homeTitle {
    return Intl.message(
      'Make sure your signatures are correct.',
      name: 'homeTitle',
      desc: '',
      args: [],
    );
  }

  /// `This app scans signatures and ensures their authenticity and safety`
  String get homeSubtitle {
    return Intl.message(
      'This app scans signatures and ensures their authenticity and safety',
      name: 'homeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Why Choose Our App?`
  String get whyChooseOurApp {
    return Intl.message(
      'Why Choose Our App?',
      name: 'whyChooseOurApp',
      desc: '',
      args: [],
    );
  }

  /// `Secure`
  String get featureSecure {
    return Intl.message(
      'Secure',
      name: 'featureSecure',
      desc: '',
      args: [],
    );
  }

  /// `Advanced security algorithms`
  String get featureSecureDesc {
    return Intl.message(
      'Advanced security algorithms',
      name: 'featureSecureDesc',
      desc: '',
      args: [],
    );
  }

  /// `Fast`
  String get featureFast {
    return Intl.message(
      'Fast',
      name: 'featureFast',
      desc: '',
      args: [],
    );
  }

  /// `Quick verification process`
  String get featureFastDesc {
    return Intl.message(
      'Quick verification process',
      name: 'featureFastDesc',
      desc: '',
      args: [],
    );
  }

  /// `Accurate`
  String get featureAccurate {
    return Intl.message(
      'Accurate',
      name: 'featureAccurate',
      desc: '',
      args: [],
    );
  }

  /// `High precision results`
  String get featureAccurateDesc {
    return Intl.message(
      'High precision results',
      name: 'featureAccurateDesc',
      desc: '',
      args: [],
    );
  }

  /// `Signature Verification`
  String get signatureVerification {
    return Intl.message(
      'Signature Verification',
      name: 'signatureVerification',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message(
      'Settings',
      name: 'settingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Customize your app experience`
  String get settingsSubtitle {
    return Intl.message(
      'Customize your app experience',
      name: 'settingsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Languages`
  String get languages {
    return Intl.message(
      'Languages',
      name: 'languages',
      desc: '',
      args: [],
    );
  }

  /// `Choose your preferred language`
  String get languagesSubtitle {
    return Intl.message(
      'Choose your preferred language',
      name: 'languagesSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message(
      'Dark Mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
  }

  /// `Switch between light and dark themes`
  String get darkModeSubtitle {
    return Intl.message(
      'Switch between light and dark themes',
      name: 'darkModeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Read our privacy and data policies`
  String get privacyPolicySubtitle {
    return Intl.message(
      'Read our privacy and data policies',
      name: 'privacyPolicySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Update your account password`
  String get changePasswordSubtitle {
    return Intl.message(
      'Update your account password',
      name: 'changePasswordSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Help & Support`
  String get helpSupport {
    return Intl.message(
      'Help & Support',
      name: 'helpSupport',
      desc: '',
      args: [],
    );
  }

  /// `Get help and contact support`
  String get helpSupportSubtitle {
    return Intl.message(
      'Get help and contact support',
      name: 'helpSupportSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `App version and information`
  String get aboutSubtitle {
    return Intl.message(
      'App version and information',
      name: 'aboutSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logout {
    return Intl.message(
      'Log Out',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Sign out of your account`
  String get logoutSubtitle {
    return Intl.message(
      'Sign out of your account',
      name: 'logoutSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Language changed to {language}`
  String languageChanged(Object language) {
    return Intl.message(
      'Language changed to $language',
      name: 'languageChanged',
      desc: '',
      args: [language],
    );
  }

  /// `{mode} mode activated`
  String darkModeActivated(Object mode) {
    return Intl.message(
      '$mode mode activated',
      name: 'darkModeActivated',
      desc: '',
      args: [mode],
    );
  }

  /// `Help & Support`
  String get helpSupportTitle {
    return Intl.message(
      'Help & Support',
      name: 'helpSupportTitle',
      desc: '',
      args: [],
    );
  }

  /// `Need help? Contact our support team:`
  String get helpContent {
    return Intl.message(
      'Need help? Contact our support team:',
      name: 'helpContent',
      desc: '',
      args: [],
    );
  }

  /// `support@inksentinel.com`
  String get supportEmail {
    return Intl.message(
      'support@inksentinel.com',
      name: 'supportEmail',
      desc: '',
      args: [],
    );
  }

  /// `+1 (555) 123-4567`
  String get supportPhone {
    return Intl.message(
      '+1 (555) 123-4567',
      name: 'supportPhone',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copyText {
    return Intl.message(
      'Copy',
      name: 'copyText',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get aboutTitle {
    return Intl.message(
      'About',
      name: 'aboutTitle',
      desc: '',
      args: [],
    );
  }

  /// `InkSentinel`
  String get appName {
    return Intl.message(
      'InkSentinel',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Version 1.0.0`
  String get version {
    return Intl.message(
      'Version 1.0.0',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Built with Flutter and powered by Firebase.`
  String get builtWith {
    return Intl.message(
      'Built with Flutter and powered by Firebase.',
      name: 'builtWith',
      desc: '',
      args: [],
    );
  }

  /// `© 2025 InkSentinel`
  String get copyright {
    return Intl.message(
      '© 2025 InkSentinel',
      name: 'copyright',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Logout`
  String get confirmLogoutTitle {
    return Intl.message(
      'Confirm Logout',
      name: 'confirmLogoutTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out? You'll need to sign in again to access your account.`
  String get confirmLogoutMessage {
    return Intl.message(
      'Are you sure you want to log out? You\'ll need to sign in again to access your account.',
      name: 'confirmLogoutMessage',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logoutAction {
    return Intl.message(
      'Log Out',
      name: 'logoutAction',
      desc: '',
      args: [],
    );
  }

  /// `Frequently Asked Questions`
  String get faqSubtitle {
    return Intl.message(
      'Frequently Asked Questions',
      name: 'faqSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap on any question below to view the answer`
  String get tapInstruction {
    return Intl.message(
      'Tap on any question below to view the answer',
      name: 'tapInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Still Need Help?`
  String get stillNeedHelp {
    return Intl.message(
      'Still Need Help?',
      name: 'stillNeedHelp',
      desc: '',
      args: [],
    );
  }

  /// `Contact our support team for personalized assistance`
  String get contactSupportPrompt {
    return Intl.message(
      'Contact our support team for personalized assistance',
      name: 'contactSupportPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Contact Support`
  String get contactSupport {
    return Intl.message(
      'Contact Support',
      name: 'contactSupport',
      desc: '',
      args: [],
    );
  }

  /// `What Exactly is InkSentinel?`
  String get question1 {
    return Intl.message(
      'What Exactly is InkSentinel?',
      name: 'question1',
      desc: '',
      args: [],
    );
  }

  /// `InkSentinel is an advanced application developed to help users and facilities verify signatures with high accuracy and security. Our app uses cutting-edge technology to detect signature authenticity.`
  String get answer1 {
    return Intl.message(
      'InkSentinel is an advanced application developed to help users and facilities verify signatures with high accuracy and security. Our app uses cutting-edge technology to detect signature authenticity.',
      name: 'answer1',
      desc: '',
      args: [],
    );
  }

  /// `How can I access the features?`
  String get question2 {
    return Intl.message(
      'How can I access the features?',
      name: 'question2',
      desc: '',
      args: [],
    );
  }

  /// `After entering the app, you'll find the home page with a signature verification button. Click on it to be transferred directly to the upload page where you can upload pictures for authenticity verification.`
  String get answer2 {
    return Intl.message(
      'After entering the app, you\'ll find the home page with a signature verification button. Click on it to be transferred directly to the upload page where you can upload pictures for authenticity verification.',
      name: 'answer2',
      desc: '',
      args: [],
    );
  }

  /// `How do I use the App?`
  String get question3 {
    return Intl.message(
      'How do I use the App?',
      name: 'question3',
      desc: '',
      args: [],
    );
  }

  /// `First, upload the picture you want to verify for authenticity. Then, upload an original signature picture so the program can make a comparison between the two images and detect any forgery.`
  String get answer3 {
    return Intl.message(
      'First, upload the picture you want to verify for authenticity. Then, upload an original signature picture so the program can make a comparison between the two images and detect any forgery.',
      name: 'answer3',
      desc: '',
      args: [],
    );
  }

  /// `How does storage work?`
  String get question4 {
    return Intl.message(
      'How does storage work?',
      name: 'question4',
      desc: '',
      args: [],
    );
  }

  /// `After completing your verification operation, all results are automatically saved. You can access your verification history anytime through the history page to review past verifications.`
  String get answer4 {
    return Intl.message(
      'After completing your verification operation, all results are automatically saved. You can access your verification history anytime through the history page to review past verifications.',
      name: 'answer4',
      desc: '',
      args: [],
    );
  }

  /// `What are your goals?`
  String get question5 {
    return Intl.message(
      'What are your goals?',
      name: 'question5',
      desc: '',
      args: [],
    );
  }

  /// `Our goal is to reduce fraud and help users, banks, and companies secure important documents and protect them from forgery. We aim to provide reliable signature verification for everyone.`
  String get answer5 {
    return Intl.message(
      'Our goal is to reduce fraud and help users, banks, and companies secure important documents and protect them from forgery. We aim to provide reliable signature verification for everyone.',
      name: 'answer5',
      desc: '',
      args: [],
    );
  }

  /// `Is my data secure?`
  String get question6 {
    return Intl.message(
      'Is my data secure?',
      name: 'question6',
      desc: '',
      args: [],
    );
  }

  /// `Yes, we prioritize your privacy and security. All uploaded images are processed securely and can be deleted from our servers upon request. We follow industry-standard security practices.`
  String get answer6 {
    return Intl.message(
      'Yes, we prioritize your privacy and security. All uploaded images are processed securely and can be deleted from our servers upon request. We follow industry-standard security practices.',
      name: 'answer6',
      desc: '',
      args: [],
    );
  }

  /// `You can reach our support team through:\n\n📧 Email: support@inksentinel.com\n📞 Phone: +1 (555) 123-4567\n💬 Live Chat: Available 24/7`
  String get contactSupportDetails {
    return Intl.message(
      'You can reach our support team through:\n\n📧 Email: support@inksentinel.com\n📞 Phone: +1 (555) 123-4567\n💬 Live Chat: Available 24/7',
      name: 'contactSupportDetails',
      desc: '',
      args: [],
    );
  }

  /// `Light mode activated`
  String get light {
    return Intl.message(
      'Light mode activated',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Dark mode activated`
  String get dark {
    return Intl.message(
      'Dark mode activated',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get arabic {
    return Intl.message(
      'Arabic',
      name: 'arabic',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back`
  String get welcomeBack {
    return Intl.message(
      'Welcome Back',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Sign in to continue`
  String get signInToContinue {
    return Intl.message(
      'Sign in to continue',
      name: 'signInToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get emailLabel {
    return Intl.message(
      'Email',
      name: 'emailLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email`
  String get emailHint {
    return Intl.message(
      'Enter your email',
      name: 'emailHint',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get passwordLabel {
    return Intl.message(
      'Password',
      name: 'passwordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get passwordHint {
    return Intl.message(
      'Enter your password',
      name: 'passwordHint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email`
  String get emailRequired {
    return Intl.message(
      'Please enter your email',
      name: 'emailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email`
  String get emailInvalid {
    return Intl.message(
      'Please enter a valid email',
      name: 'emailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get passwordRequired {
    return Intl.message(
      'Please enter your password',
      name: 'passwordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get passwordTooShort {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordTooShort',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signInButton {
    return Intl.message(
      'Sign In',
      name: 'signInButton',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account? `
  String get noAccount {
    return Intl.message(
      'Don\'t have an account? ',
      name: 'noAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signUp {
    return Intl.message(
      'Sign Up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `No account found with this email.`
  String get userNotFound {
    return Intl.message(
      'No account found with this email.',
      name: 'userNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password.`
  String get wrongPassword {
    return Intl.message(
      'Incorrect password.',
      name: 'wrongPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email.`
  String get invalidEmail {
    return Intl.message(
      'Please enter a valid email.',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Too many attempts. Please try again later.`
  String get tooManyRequests {
    return Intl.message(
      'Too many attempts. Please try again later.',
      name: 'tooManyRequests',
      desc: '',
      args: [],
    );
  }

  /// `Login failed. Please try again.`
  String get loginFailed {
    return Intl.message(
      'Login failed. Please try again.',
      name: 'loginFailed',
      desc: '',
      args: [],
    );
  }

  /// `Verification email sent. Please check your inbox.`
  String get verificationEmailSent {
    return Intl.message(
      'Verification email sent. Please check your inbox.',
      name: 'verificationEmailSent',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred.`
  String get unexpectedError {
    return Intl.message(
      'An unexpected error occurred.',
      name: 'unexpectedError',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign up to get started`
  String get signUpToGetStarted {
    return Intl.message(
      'Sign up to get started',
      name: 'signUpToGetStarted',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm your password`
  String get confirmPasswordHint {
    return Intl.message(
      'Confirm your password',
      name: 'confirmPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your password`
  String get confirmPasswordRequired {
    return Intl.message(
      'Please confirm your password',
      name: 'confirmPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Passwords don't match`
  String get passwordsDontMatch {
    return Intl.message(
      'Passwords don\'t match',
      name: 'passwordsDontMatch',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccountButton {
    return Intl.message(
      'Create Account',
      name: 'createAccountButton',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? `
  String get alreadyHaveAccount {
    return Intl.message(
      'Already have an account? ',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signIn {
    return Intl.message(
      'Sign In',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Password is too weak. Use at least 8 characters with uppercase, lowercase, numbers and special characters.`
  String get weakPassword {
    return Intl.message(
      'Password is too weak. Use at least 8 characters with uppercase, lowercase, numbers and special characters.',
      name: 'weakPassword',
      desc: '',
      args: [],
    );
  }

  /// `An account already exists with this email.`
  String get emailAlreadyInUse {
    return Intl.message(
      'An account already exists with this email.',
      name: 'emailAlreadyInUse',
      desc: '',
      args: [],
    );
  }

  /// `Account creation is currently disabled.`
  String get operationNotAllowed {
    return Intl.message(
      'Account creation is currently disabled.',
      name: 'operationNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Registration failed. Please try again.`
  String get registrationFailed {
    return Intl.message(
      'Registration failed. Please try again.',
      name: 'registrationFailed',
      desc: '',
      args: [],
    );
  }

  /// `A verification email has been sent to your email address. Please verify your email before signing in.`
  String get verificationSent {
    return Intl.message(
      'A verification email has been sent to your email address. Please verify your email before signing in.',
      name: 'verificationSent',
      desc: '',
      args: [],
    );
  }

  /// `Account Created!`
  String get accountCreated {
    return Intl.message(
      'Account Created!',
      name: 'accountCreated',
      desc: '',
      args: [],
    );
  }

  /// `Continue to Login`
  String get continueToLogin {
    return Intl.message(
      'Continue to Login',
      name: 'continueToLogin',
      desc: '',
      args: [],
    );
  }

  /// `Weak`
  String get weak {
    return Intl.message(
      'Weak',
      name: 'weak',
      desc: '',
      args: [],
    );
  }

  /// `Fair`
  String get fair {
    return Intl.message(
      'Fair',
      name: 'fair',
      desc: '',
      args: [],
    );
  }

  /// `Good`
  String get good {
    return Intl.message(
      'Good',
      name: 'good',
      desc: '',
      args: [],
    );
  }

  /// `Strong`
  String get strong {
    return Intl.message(
      'Strong',
      name: 'strong',
      desc: '',
      args: [],
    );
  }

  /// `Password must be Good or Strong. Please improve your password.`
  String get passwordStrengthWarning {
    return Intl.message(
      'Password must be Good or Strong. Please improve your password.',
      name: 'passwordStrengthWarning',
      desc: '',
      args: [],
    );
  }

  /// `Good or Strong required`
  String get goodStrongRequired {
    return Intl.message(
      'Good or Strong required',
      name: 'goodStrongRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password should include:`
  String get passwordShouldInclude {
    return Intl.message(
      'Password should include:',
      name: 'passwordShouldInclude',
      desc: '',
      args: [],
    );
  }

  /// `At least 8 characters`
  String get atLeast8Chars {
    return Intl.message(
      'At least 8 characters',
      name: 'atLeast8Chars',
      desc: '',
      args: [],
    );
  }

  /// `Uppercase letter (A-Z)`
  String get uppercaseLetter {
    return Intl.message(
      'Uppercase letter (A-Z)',
      name: 'uppercaseLetter',
      desc: '',
      args: [],
    );
  }

  /// `Number (0-9)`
  String get numberDigit {
    return Intl.message(
      'Number (0-9)',
      name: 'numberDigit',
      desc: '',
      args: [],
    );
  }

  /// `Special character (!@#%^&*)`
  String get specialChar {
    return Intl.message(
      'Special character (!@#%^&*)',
      name: 'specialChar',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPassword {
    return Intl.message(
      'Reset Password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Don't worry! Enter your email address and we'll send you a link to reset your password.`
  String get resetInstructions {
    return Intl.message(
      'Don\'t worry! Enter your email address and we\'ll send you a link to reset your password.',
      name: 'resetInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Send Reset Link`
  String get sendResetLink {
    return Intl.message(
      'Send Reset Link',
      name: 'sendResetLink',
      desc: '',
      args: [],
    );
  }

  /// `Back to Sign In`
  String get backToSignIn {
    return Intl.message(
      'Back to Sign In',
      name: 'backToSignIn',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send reset email. Please try again.`
  String get resetFailed {
    return Intl.message(
      'Failed to send reset email. Please try again.',
      name: 'resetFailed',
      desc: '',
      args: [],
    );
  }

  /// `Check Your Email!`
  String get checkEmail {
    return Intl.message(
      'Check Your Email!',
      name: 'checkEmail',
      desc: '',
      args: [],
    );
  }

  /// `We've sent a password reset link to:`
  String get resetSent {
    return Intl.message(
      'We\'ve sent a password reset link to:',
      name: 'resetSent',
      desc: '',
      args: [],
    );
  }

  /// `Didn't receive the email? Resend`
  String get resendEmail {
    return Intl.message(
      'Didn\'t receive the email? Resend',
      name: 'resendEmail',
      desc: '',
      args: [],
    );
  }

  /// `Secure Your Account`
  String get secureAccount {
    return Intl.message(
      'Secure Your Account',
      name: 'secureAccount',
      desc: '',
      args: [],
    );
  }

  /// `Create a strong password to keep your account safe`
  String get createStrongPassword {
    return Intl.message(
      'Create a strong password to keep your account safe',
      name: 'createStrongPassword',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get currentPassword {
    return Intl.message(
      'Current Password',
      name: 'currentPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter your current password`
  String get currentPasswordHint {
    return Intl.message(
      'Enter your current password',
      name: 'currentPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your current password`
  String get currentPasswordRequired {
    return Intl.message(
      'Please enter your current password',
      name: 'currentPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter your new password`
  String get newPasswordHint {
    return Intl.message(
      'Enter your new password',
      name: 'newPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your new password`
  String get newPasswordRequired {
    return Intl.message(
      'Please enter your new password',
      name: 'newPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password must contain uppercase, lowercase, number and special character`
  String get passwordComplexity {
    return Intl.message(
      'Password must contain uppercase, lowercase, number and special character',
      name: 'passwordComplexity',
      desc: '',
      args: [],
    );
  }

  /// `Update Password`
  String get updatePassword {
    return Intl.message(
      'Update Password',
      name: 'updatePassword',
      desc: '',
      args: [],
    );
  }

  /// `Password updated successfully!`
  String get passwordUpdated {
    return Intl.message(
      'Password updated successfully!',
      name: 'passwordUpdated',
      desc: '',
      args: [],
    );
  }

  /// `No user is currently logged in`
  String get noUserLoggedIn {
    return Intl.message(
      'No user is currently logged in',
      name: 'noUserLoggedIn',
      desc: '',
      args: [],
    );
  }

  /// `Current password is incorrect`
  String get incorrectPassword {
    return Intl.message(
      'Current password is incorrect',
      name: 'incorrectPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please log in again to change your password`
  String get recentLoginRequired {
    return Intl.message(
      'Please log in again to change your password',
      name: 'recentLoginRequired',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update password. Please try again`
  String get passwordUpdateFailed {
    return Intl.message(
      'Failed to update password. Please try again',
      name: 'passwordUpdateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Verification History`
  String get verificationHistory {
    return Intl.message(
      'Verification History',
      name: 'verificationHistory',
      desc: '',
      args: [],
    );
  }

  /// `Go back`
  String get goBack {
    return Intl.message(
      'Go back',
      name: 'goBack',
      desc: '',
      args: [],
    );
  }

  /// `Information`
  String get information {
    return Intl.message(
      'Information',
      name: 'information',
      desc: '',
      args: [],
    );
  }

  /// `Search results...`
  String get searchResults {
    return Intl.message(
      'Search results...',
      name: 'searchResults',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message(
      'Filter',
      name: 'filter',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Valid`
  String get valid {
    return Intl.message(
      'Valid',
      name: 'valid',
      desc: '',
      args: [],
    );
  }

  /// `Fake`
  String get fake {
    return Intl.message(
      'Fake',
      name: 'fake',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }

  /// `Unknown date`
  String get unknownDate {
    return Intl.message(
      'Unknown date',
      name: 'unknownDate',
      desc: '',
      args: [],
    );
  }

  /// `Invalid date`
  String get invalidDate {
    return Intl.message(
      'Invalid date',
      name: 'invalidDate',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message(
      'Yesterday',
      name: 'yesterday',
      desc: '',
      args: [],
    );
  }

  /// `Delete entry`
  String get deleteEntry {
    return Intl.message(
      'Delete entry',
      name: 'deleteEntry',
      desc: '',
      args: [],
    );
  }

  /// `Loading history...`
  String get loadingHistory {
    return Intl.message(
      'Loading history...',
      name: 'loadingHistory',
      desc: '',
      args: [],
    );
  }

  /// `No History Available`
  String get noHistory {
    return Intl.message(
      'No History Available',
      name: 'noHistory',
      desc: '',
      args: [],
    );
  }

  /// `Your verification results will appear here`
  String get historyWillAppear {
    return Intl.message(
      'Your verification results will appear here',
      name: 'historyWillAppear',
      desc: '',
      args: [],
    );
  }

  /// `No Results Found`
  String get noResults {
    return Intl.message(
      'No Results Found',
      name: 'noResults',
      desc: '',
      args: [],
    );
  }

  /// `Try adjusting your search or filter`
  String get adjustSearch {
    return Intl.message(
      'Try adjusting your search or filter',
      name: 'adjustSearch',
      desc: '',
      args: [],
    );
  }

  /// `Error Loading History`
  String get errorLoading {
    return Intl.message(
      'Error Loading History',
      name: 'errorLoading',
      desc: '',
      args: [],
    );
  }

  /// `Please try again later`
  String get tryAgainLater {
    return Intl.message(
      'Please try again later',
      name: 'tryAgainLater',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Verification Details`
  String get verificationDetails {
    return Intl.message(
      'Verification Details',
      name: 'verificationDetails',
      desc: '',
      args: [],
    );
  }

  /// `Result`
  String get result {
    return Intl.message(
      'Result',
      name: 'result',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Platform`
  String get platform {
    return Intl.message(
      'Platform',
      name: 'platform',
      desc: '',
      args: [],
    );
  }

  /// `About History`
  String get aboutHistory {
    return Intl.message(
      'About History',
      name: 'aboutHistory',
      desc: '',
      args: [],
    );
  }

  /// `This page shows all your signature verification results. You can:\n\n• Search through your results\n• Filter by verification status\n• Tap an item to view details\n• Long press or tap delete to remove entries\n\nResults are automatically synced across your devices.`
  String get historyPageInfo {
    return Intl.message(
      'This page shows all your signature verification results. You can:\n\n• Search through your results\n• Filter by verification status\n• Tap an item to view details\n• Long press or tap delete to remove entries\n\nResults are automatically synced across your devices.',
      name: 'historyPageInfo',
      desc: '',
      args: [],
    );
  }

  /// `Got it`
  String get gotIt {
    return Intl.message(
      'Got it',
      name: 'gotIt',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Deletion`
  String get confirmDeletion {
    return Intl.message(
      'Confirm Deletion',
      name: 'confirmDeletion',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this verification result? This action cannot be undone.`
  String get deleteConfirmation {
    return Intl.message(
      'Are you sure you want to delete this verification result? This action cannot be undone.',
      name: 'deleteConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Entry deleted successfully`
  String get entryDeleted {
    return Intl.message(
      'Entry deleted successfully',
      name: 'entryDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete entry`
  String get deleteFailed {
    return Intl.message(
      'Failed to delete entry',
      name: 'deleteFailed',
      desc: '',
      args: [],
    );
  }

  /// `Permission denied. Please check your access rights.`
  String get permissionDenied {
    return Intl.message(
      'Permission denied. Please check your access rights.',
      name: 'permissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Entry not found. It may have been already deleted.`
  String get entryNotFound {
    return Intl.message(
      'Entry not found. It may have been already deleted.',
      name: 'entryNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Service temporarily unavailable. Please try again.`
  String get serviceUnavailable {
    return Intl.message(
      'Service temporarily unavailable. Please try again.',
      name: 'serviceUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message(
      'Help',
      name: 'help',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      args: [],
    );
  }

  /// `Add Account`
  String get addAccount {
    return Intl.message(
      'Add Account',
      name: 'addAccount',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logOut {
    return Intl.message(
      'Log Out',
      name: 'logOut',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Logout`
  String get confirmLogout {
    return Intl.message(
      'Confirm Logout',
      name: 'confirmLogout',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get areYouSureLogout {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'areYouSureLogout',
      desc: '',
      args: [],
    );
  }

  /// `Verification`
  String get verification {
    return Intl.message(
      'Verification',
      name: 'verification',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicyTitle {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your privacy is important to us. Please review our policies below.`
  String get privacyPolicySubtitle2 {
    return Intl.message(
      'Your privacy is important to us. Please review our policies below.',
      name: 'privacyPolicySubtitle2',
      desc: '',
      args: [],
    );
  }

  /// `Last updated: April 2025`
  String get privacyLastUpdated {
    return Intl.message(
      'Last updated: April 2025',
      name: 'privacyLastUpdated',
      desc: '',
      args: [],
    );
  }

  /// `If you have any questions about this Privacy Policy, please contact us.`
  String get privacyContact {
    return Intl.message(
      'If you have any questions about this Privacy Policy, please contact us.',
      name: 'privacyContact',
      desc: '',
      args: [],
    );
  }

  /// `Information We Collect`
  String get policy1Title {
    return Intl.message(
      'Information We Collect',
      name: 'policy1Title',
      desc: '',
      args: [],
    );
  }

  /// `We collect information such as email and password during registration. This may also include device information, usage patterns, and preferences to enhance your experience with our application.`
  String get policy1Content {
    return Intl.message(
      'We collect information such as email and password during registration. This may also include device information, usage patterns, and preferences to enhance your experience with our application.',
      name: 'policy1Content',
      desc: '',
      args: [],
    );
  }

  /// `How We Use the Information`
  String get policy2Title {
    return Intl.message(
      'How We Use the Information',
      name: 'policy2Title',
      desc: '',
      args: [],
    );
  }

  /// `We use the information to provide and improve our verification services. Your data helps us personalize your experience, send important notifications, and maintain the security of our platform.`
  String get policy2Content {
    return Intl.message(
      'We use the information to provide and improve our verification services. Your data helps us personalize your experience, send important notifications, and maintain the security of our platform.',
      name: 'policy2Content',
      desc: '',
      args: [],
    );
  }

  /// `Information Sharing`
  String get policy3Title {
    return Intl.message(
      'Information Sharing',
      name: 'policy3Title',
      desc: '',
      args: [],
    );
  }

  /// `We do not share your personal information with third parties without your explicit consent, except where required by law or to protect our users' safety and security.`
  String get policy3Content {
    return Intl.message(
      'We do not share your personal information with third parties without your explicit consent, except where required by law or to protect our users\' safety and security.',
      name: 'policy3Content',
      desc: '',
      args: [],
    );
  }

  /// `Data Security`
  String get policy4Title {
    return Intl.message(
      'Data Security',
      name: 'policy4Title',
      desc: '',
      args: [],
    );
  }

  /// `We implement industry-standard security measures to protect your data from unauthorized access, including encryption, secure servers, and regular security audits.`
  String get policy4Content {
    return Intl.message(
      'We implement industry-standard security measures to protect your data from unauthorized access, including encryption, secure servers, and regular security audits.',
      name: 'policy4Content',
      desc: '',
      args: [],
    );
  }

  /// `Your Rights`
  String get policy5Title {
    return Intl.message(
      'Your Rights',
      name: 'policy5Title',
      desc: '',
      args: [],
    );
  }

  /// `You have the right to access, modify, or delete your personal data. You can also opt-out of certain communications and data processing activities at any time.`
  String get policy5Content {
    return Intl.message(
      'You have the right to access, modify, or delete your personal data. You can also opt-out of certain communications and data processing activities at any time.',
      name: 'policy5Content',
      desc: '',
      args: [],
    );
  }

  /// `Changes to This Policy`
  String get policy6Title {
    return Intl.message(
      'Changes to This Policy',
      name: 'policy6Title',
      desc: '',
      args: [],
    );
  }

  /// `We may update this policy from time to time to reflect changes in our practices or legal requirements. You will be notified of any significant changes through the app or email.`
  String get policy6Content {
    return Intl.message(
      'We may update this policy from time to time to reflect changes in our practices or legal requirements. You will be notified of any significant changes through the app or email.',
      name: 'policy6Content',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get splashWelcome {
    return Intl.message(
      'Welcome',
      name: 'splashWelcome',
      desc: '',
      args: [],
    );
  }

  /// `Getting things ready...`
  String get splashGettingReady {
    return Intl.message(
      'Getting things ready...',
      name: 'splashGettingReady',
      desc: '',
      args: [],
    );
  }

  /// `Verification`
  String get verificationTitle {
    return Intl.message(
      'Verification',
      name: 'verificationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Upload Original Signature`
  String get uploadOriginalSignature {
    return Intl.message(
      'Upload Original Signature',
      name: 'uploadOriginalSignature',
      desc: '',
      args: [],
    );
  }

  /// `Please upload a clear image of the original signature for verification`
  String get uploadOriginalSignatureDescription {
    return Intl.message(
      'Please upload a clear image of the original signature for verification',
      name: 'uploadOriginalSignatureDescription',
      desc: '',
      args: [],
    );
  }

  /// `Tap to Upload Image`
  String get tapToUploadImage {
    return Intl.message(
      'Tap to Upload Image',
      name: 'tapToUploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Drag and drop or click to browse`
  String get dragOrClickInstruction {
    return Intl.message(
      'Drag and drop or click to browse',
      name: 'dragOrClickInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Upload Signature`
  String get uploadSignatureButton {
    return Intl.message(
      'Upload Signature',
      name: 'uploadSignatureButton',
      desc: '',
      args: [],
    );
  }

  /// `Upload Guidelines`
  String get uploadGuidelines {
    return Intl.message(
      'Upload Guidelines',
      name: 'uploadGuidelines',
      desc: '',
      args: [],
    );
  }

  /// `High Quality`
  String get highQuality {
    return Intl.message(
      'High Quality',
      name: 'highQuality',
      desc: '',
      args: [],
    );
  }

  /// `Use clear, high-resolution images`
  String get highQualityDescription {
    return Intl.message(
      'Use clear, high-resolution images',
      name: 'highQualityDescription',
      desc: '',
      args: [],
    );
  }

  /// `Good Lighting`
  String get goodLighting {
    return Intl.message(
      'Good Lighting',
      name: 'goodLighting',
      desc: '',
      args: [],
    );
  }

  /// `Ensure proper lighting conditions`
  String get goodLightingDescription {
    return Intl.message(
      'Ensure proper lighting conditions',
      name: 'goodLightingDescription',
      desc: '',
      args: [],
    );
  }

  /// `Proper Frame`
  String get properFrame {
    return Intl.message(
      'Proper Frame',
      name: 'properFrame',
      desc: '',
      args: [],
    );
  }

  /// `Keep signature within frame`
  String get properFrameDescription {
    return Intl.message(
      'Keep signature within frame',
      name: 'properFrameDescription',
      desc: '',
      args: [],
    );
  }

  /// `Choose Image Source`
  String get chooseImageSource {
    return Intl.message(
      'Choose Image Source',
      name: 'chooseImageSource',
      desc: '',
      args: [],
    );
  }

  /// `Select how you want to add your signature`
  String get selectSourceDescription {
    return Intl.message(
      'Select how you want to add your signature',
      name: 'selectSourceDescription',
      desc: '',
      args: [],
    );
  }

  /// `Choose from Gallery`
  String get chooseFromGallery {
    return Intl.message(
      'Choose from Gallery',
      name: 'chooseFromGallery',
      desc: '',
      args: [],
    );
  }

  /// `Select from your photo library`
  String get galleryDescription {
    return Intl.message(
      'Select from your photo library',
      name: 'galleryDescription',
      desc: '',
      args: [],
    );
  }

  /// `Take a Photo`
  String get takePhoto {
    return Intl.message(
      'Take a Photo',
      name: 'takePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Use camera to capture signature`
  String get cameraDescription {
    return Intl.message(
      'Use camera to capture signature',
      name: 'cameraDescription',
      desc: '',
      args: [],
    );
  }

  /// `Processing image...`
  String get processingImage {
    return Intl.message(
      'Processing image...',
      name: 'processingImage',
      desc: '',
      args: [],
    );
  }

  /// `No image selected`
  String get noImageSelected {
    return Intl.message(
      'No image selected',
      name: 'noImageSelected',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Upload Images`
  String get uploadImages {
    return Intl.message(
      'Upload Images',
      name: 'uploadImages',
      desc: '',
      args: [],
    );
  }

  /// `Please Upload Original Signature`
  String get uploadOriginalSignatureTitle {
    return Intl.message(
      'Please Upload Original Signature',
      name: 'uploadOriginalSignatureTitle',
      desc: '',
      args: [],
    );
  }

  /// `Change Image`
  String get changeImage {
    return Intl.message(
      'Change Image',
      name: 'changeImage',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load image`
  String get failedToLoadImage {
    return Intl.message(
      'Failed to load image',
      name: 'failedToLoadImage',
      desc: '',
      args: [],
    );
  }

  /// `Failed to open image selector`
  String get failedToOpenSelector {
    return Intl.message(
      'Failed to open image selector',
      name: 'failedToOpenSelector',
      desc: '',
      args: [],
    );
  }

  /// `Image file not found`
  String get imageFileNotFound {
    return Intl.message(
      'Image file not found',
      name: 'imageFileNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Failed to proceed. Please try again.`
  String get failedToProceed {
    return Intl.message(
      'Failed to proceed. Please try again.',
      name: 'failedToProceed',
      desc: '',
      args: [],
    );
  }

  /// `Upload Current Signature`
  String get uploadCurrentSignature {
    return Intl.message(
      'Upload Current Signature',
      name: 'uploadCurrentSignature',
      desc: '',
      args: [],
    );
  }

  /// `Upload a clear image of the signature to compare with the original`
  String get uploadCurrentSignatureDescription {
    return Intl.message(
      'Upload a clear image of the signature to compare with the original',
      name: 'uploadCurrentSignatureDescription',
      desc: '',
      args: [],
    );
  }

  /// `Compare with Original`
  String get compareWithOriginal {
    return Intl.message(
      'Compare with Original',
      name: 'compareWithOriginal',
      desc: '',
      args: [],
    );
  }

  /// `Tap to upload current signature`
  String get tapToUploadCurrentSignature {
    return Intl.message(
      'Tap to upload current signature',
      name: 'tapToUploadCurrentSignature',
      desc: '',
      args: [],
    );
  }

  /// `Upload Current Signature`
  String get uploadCurrentSignatureButton {
    return Intl.message(
      'Upload Current Signature',
      name: 'uploadCurrentSignatureButton',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message(
      'Verify',
      name: 'verify',
      desc: '',
      args: [],
    );
  }

  /// `Verification Process`
  String get verificationProcess {
    return Intl.message(
      'Verification Process',
      name: 'verificationProcess',
      desc: '',
      args: [],
    );
  }

  /// `Original Signature`
  String get originalSignature {
    return Intl.message(
      'Original Signature',
      name: 'originalSignature',
      desc: '',
      args: [],
    );
  }

  /// `Stored securely for comparison`
  String get originalSignatureDescription {
    return Intl.message(
      'Stored securely for comparison',
      name: 'originalSignatureDescription',
      desc: '',
      args: [],
    );
  }

  /// `Pattern Matching`
  String get patternMatching {
    return Intl.message(
      'Pattern Matching',
      name: 'patternMatching',
      desc: '',
      args: [],
    );
  }

  /// `AI-powered signature analysis`
  String get patternMatchingDescription {
    return Intl.message(
      'AI-powered signature analysis',
      name: 'patternMatchingDescription',
      desc: '',
      args: [],
    );
  }

  /// `Secure Results`
  String get secureResults {
    return Intl.message(
      'Secure Results',
      name: 'secureResults',
      desc: '',
      args: [],
    );
  }

  /// `Encrypted verification report`
  String get secureResultsDescription {
    return Intl.message(
      'Encrypted verification report',
      name: 'secureResultsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Original signature uploaded`
  String get originalSignatureUploaded {
    return Intl.message(
      'Original signature uploaded',
      name: 'originalSignatureUploaded',
      desc: '',
      args: [],
    );
  }

  /// `Processing current signature...`
  String get processingCurrentSignature {
    return Intl.message(
      'Processing current signature...',
      name: 'processingCurrentSignature',
      desc: '',
      args: [],
    );
  }

  /// `Chat with AI Assistant`
  String get chatWithAI {
    return Intl.message(
      'Chat with AI Assistant',
      name: 'chatWithAI',
      desc: '',
      args: [],
    );
  }

  /// `Learn more about our app and get instant answers`
  String get chatbotDescription {
    return Intl.message(
      'Learn more about our app and get instant answers',
      name: 'chatbotDescription',
      desc: '',
      args: [],
    );
  }

  /// `Start Chat`
  String get startChat {
    return Intl.message(
      'Start Chat',
      name: 'startChat',
      desc: '',
      args: [],
    );
  }

  /// `AI Assistant`
  String get chatbotTitle {
    return Intl.message(
      'AI Assistant',
      name: 'chatbotTitle',
      desc: '',
      args: [],
    );
  }

  /// `AI Assistant`
  String get aiAssistant {
    return Intl.message(
      'AI Assistant',
      name: 'aiAssistant',
      desc: '',
      args: [],
    );
  }

  /// `Online • Ready to help`
  String get onlineStatus {
    return Intl.message(
      'Online • Ready to help',
      name: 'onlineStatus',
      desc: '',
      args: [],
    );
  }

  /// `Type your message...`
  String get typeMessage {
    return Intl.message(
      'Type your message...',
      name: 'typeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Hello! I'm your AI assistant...`
  String get chatbotWelcome {
    return Intl.message(
      'Hello! I\'m your AI assistant...',
      name: 'chatbotWelcome',
      desc: '',
      args: [],
    );
  }

  /// `Our app offers powerful note-taking capabilities with AI assistance, cloud sync, rich text formatting, voice notes, document scanning, and collaborative features. You can organize your thoughts seamlessly and access them anywhere!`
  String get chatbotFeatures {
    return Intl.message(
      'Our app offers powerful note-taking capabilities with AI assistance, cloud sync, rich text formatting, voice notes, document scanning, and collaborative features. You can organize your thoughts seamlessly and access them anywhere!',
      name: 'chatbotFeatures',
      desc: '',
      args: [],
    );
  }

  /// `InkSentinel is an intelligent note-taking app designed to enhance your productivity. We combine traditional note-taking with AI-powered features to help you capture, organize, and retrieve information more effectively.`
  String get chatbotAbout {
    return Intl.message(
      'InkSentinel is an intelligent note-taking app designed to enhance your productivity. We combine traditional note-taking with AI-powered features to help you capture, organize, and retrieve information more effectively.',
      name: 'chatbotAbout',
      desc: '',
      args: [],
    );
  }

  /// `Getting started is easy! Create your first note by tapping the '+' button, use our AI assistant to organize content, sync across devices, and explore features like voice notes and document scanning. Would you like specific guidance on any feature?`
  String get chatbotHowTo {
    return Intl.message(
      'Getting started is easy! Create your first note by tapping the \'+\' button, use our AI assistant to organize content, sync across devices, and explore features like voice notes and document scanning. Would you like specific guidance on any feature?',
      name: 'chatbotHowTo',
      desc: '',
      args: [],
    );
  }

  /// `We offer both free and premium plans. The free plan includes basic note-taking features, while premium unlocks advanced AI capabilities, unlimited cloud storage, and collaboration tools. Check our pricing page for detailed information!`
  String get chatbotPricing {
    return Intl.message(
      'We offer both free and premium plans. The free plan includes basic note-taking features, while premium unlocks advanced AI capabilities, unlimited cloud storage, and collaboration tools. Check our pricing page for detailed information!',
      name: 'chatbotPricing',
      desc: '',
      args: [],
    );
  }

  /// `I'm here to help! For technical issues, you can contact our support team through the Help section. For general questions about features or usage, feel free to ask me directly. What specific help do you need?`
  String get chatbotSupport {
    return Intl.message(
      'I\'m here to help! For technical issues, you can contact our support team through the Help section. For general questions about features or usage, feel free to ask me directly. What specific help do you need?',
      name: 'chatbotSupport',
      desc: '',
      args: [],
    );
  }

  /// `Your privacy and data security are our top priorities. We use end-to-end encryption for all notes, secure cloud storage, and never share your personal information. Your notes remain completely private and secure.`
  String get chatbotSecurity {
    return Intl.message(
      'Your privacy and data security are our top priorities. We use end-to-end encryption for all notes, secure cloud storage, and never share your personal information. Your notes remain completely private and secure.',
      name: 'chatbotSecurity',
      desc: '',
      args: [],
    );
  }

  /// `That's a great question! Could you provide more details so I can give you the most helpful answer? I'm here to help with anything related to our app, features, usage, or general questions.`
  String get chatbotDefault {
    return Intl.message(
      'That\'s a great question! Could you provide more details so I can give you the most helpful answer? I\'m here to help with anything related to our app, features, usage, or general questions.',
      name: 'chatbotDefault',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
