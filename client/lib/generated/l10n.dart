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
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
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
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Cancel`
  String get selectDateCancel {
    return Intl.message('Cancel', name: 'selectDateCancel', desc: '', args: []);
  }

  /// `OK`
  String get selectDateOk {
    return Intl.message('OK', name: 'selectDateOk', desc: '', args: []);
  }

  /// `Selected:`
  String get selectDateSelected {
    return Intl.message(
      'Selected:',
      name: 'selectDateSelected',
      desc: '',
      args: [],
    );
  }

  /// `HH`
  String get selectDateHourLabel {
    return Intl.message('HH', name: 'selectDateHourLabel', desc: '', args: []);
  }

  /// `MM`
  String get selectDateMinuteLabel {
    return Intl.message(
      'MM',
      name: 'selectDateMinuteLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid hour (0-23) and minute (0-59).`
  String get selectDateInvalidHourMinute {
    return Intl.message(
      'Please enter a valid hour (0-23) and minute (0-59).',
      name: 'selectDateInvalidHourMinute',
      desc: '',
      args: [],
    );
  }

  /// `Redaction Date`
  String get agendaPageActualName {
    return Intl.message(
      'Redaction Date',
      name: 'agendaPageActualName',
      desc: '',
      args: [],
    );
  }

  /// `Meeting Title`
  String get agendaPageTitle {
    return Intl.message(
      'Meeting Title',
      name: 'agendaPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Goals of the meeting`
  String get agendaPageGoals {
    return Intl.message(
      'Goals of the meeting',
      name: 'agendaPageGoals',
      desc: '',
      args: [],
    );
  }

  /// `Meeting Location`
  String get agendaPageLocation {
    return Intl.message(
      'Meeting Location',
      name: 'agendaPageLocation',
      desc: '',
      args: [],
    );
  }

  /// `Meeting on {date}`
  String agendaPageMeetingOn(Object date) {
    return Intl.message(
      'Meeting on $date',
      name: 'agendaPageMeetingOn',
      desc: '',
      args: [date],
    );
  }

  /// `Agenda`
  String get agendaPageTitleAppBar {
    return Intl.message(
      'Agenda',
      name: 'agendaPageTitleAppBar',
      desc: '',
      args: [],
    );
  }

  /// `Meeting Details`
  String get agendaPageSectionMeetingDetails {
    return Intl.message(
      'Meeting Details',
      name: 'agendaPageSectionMeetingDetails',
      desc: '',
      args: [],
    );
  }

  /// `Schedule & Location`
  String get agendaPageSectionScheduleLocation {
    return Intl.message(
      'Schedule & Location',
      name: 'agendaPageSectionScheduleLocation',
      desc: '',
      args: [],
    );
  }

  /// `Themes`
  String get agendaPageSectionThemes {
    return Intl.message(
      'Themes',
      name: 'agendaPageSectionThemes',
      desc: '',
      args: [],
    );
  }

  /// `People`
  String get agendaPageSectionPeople {
    return Intl.message(
      'People',
      name: 'agendaPageSectionPeople',
      desc: '',
      args: [],
    );
  }

  /// `Animator`
  String get agendaPageAnimatorLabel {
    return Intl.message(
      'Animator',
      name: 'agendaPageAnimatorLabel',
      desc: '',
      args: [],
    );
  }

  /// `Add participant`
  String get agendaPageAddParticipant {
    return Intl.message(
      'Add participant',
      name: 'agendaPageAddParticipant',
      desc: '',
      args: [],
    );
  }

  /// `Add theme`
  String get agendaPageAddTheme {
    return Intl.message(
      'Add theme',
      name: 'agendaPageAddTheme',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get agendaPageCancel {
    return Intl.message('Cancel', name: 'agendaPageCancel', desc: '', args: []);
  }

  /// `Save Agenda`
  String get agendaPageSaveAgenda {
    return Intl.message(
      'Save Agenda',
      name: 'agendaPageSaveAgenda',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email or password.`
  String get authServiceInvalidCredentials {
    return Intl.message(
      'Invalid email or password.',
      name: 'authServiceInvalidCredentials',
      desc: '',
      args: [],
    );
  }

  /// `Account not found.`
  String get authServiceUnknownAccount {
    return Intl.message(
      'Account not found.',
      name: 'authServiceUnknownAccount',
      desc: '',
      args: [],
    );
  }

  /// `An unknown error occurred during authentication.`
  String get authServiceUnknownError {
    return Intl.message(
      'An unknown error occurred during authentication.',
      name: 'authServiceUnknownError',
      desc: '',
      args: [],
    );
  }

  /// `Username is invalid or already taken.`
  String get authServiceUsernameError {
    return Intl.message(
      'Username is invalid or already taken.',
      name: 'authServiceUsernameError',
      desc: '',
      args: [],
    );
  }

  /// `Email is invalid or already registered.`
  String get authServiceEmailError {
    return Intl.message(
      'Email is invalid or already registered.',
      name: 'authServiceEmailError',
      desc: '',
      args: [],
    );
  }

  /// `Password is too weak or invalid.`
  String get authServicePasswordError {
    return Intl.message(
      'Password is too weak or invalid.',
      name: 'authServicePasswordError',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signupPageTitle {
    return Intl.message('Sign Up', name: 'signupPageTitle', desc: '', args: []);
  }

  /// `Email`
  String get signupPageLabelEmail {
    return Intl.message(
      'Email',
      name: 'signupPageLabelEmail',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get signupPageLabelUsername {
    return Intl.message(
      'Username',
      name: 'signupPageLabelUsername',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get signupPageLabelPassword {
    return Intl.message(
      'Password',
      name: 'signupPageLabelPassword',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signupPageButtonSignup {
    return Intl.message(
      'Sign Up',
      name: 'signupPageButtonSignup',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? Login`
  String get signupPageLinkLogin {
    return Intl.message(
      'Already have an account? Login',
      name: 'signupPageLinkLogin',
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
      Locale.fromSubtags(languageCode: 'fr'),
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
