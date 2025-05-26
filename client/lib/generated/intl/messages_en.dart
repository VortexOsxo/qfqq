// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(date) => "Meeting on ${date}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "agendaPageActualName": MessageLookupByLibrary.simpleMessage(
      "Redaction Date",
    ),
    "agendaPageAddParticipant": MessageLookupByLibrary.simpleMessage(
      "Add participant",
    ),
    "agendaPageAddTheme": MessageLookupByLibrary.simpleMessage("Add theme"),
    "agendaPageAnimatorLabel": MessageLookupByLibrary.simpleMessage("Animator"),
    "agendaPageCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "agendaPageGoals": MessageLookupByLibrary.simpleMessage(
      "Goals of the meeting",
    ),
    "agendaPageLocation": MessageLookupByLibrary.simpleMessage(
      "Meeting Location",
    ),
    "agendaPageMeetingOn": m0,
    "agendaPageSaveAgenda": MessageLookupByLibrary.simpleMessage("Save Agenda"),
    "agendaPageSectionMeetingDetails": MessageLookupByLibrary.simpleMessage(
      "Meeting Details",
    ),
    "agendaPageSectionPeople": MessageLookupByLibrary.simpleMessage("People"),
    "agendaPageSectionScheduleLocation": MessageLookupByLibrary.simpleMessage(
      "Schedule & Location",
    ),
    "agendaPageSectionThemes": MessageLookupByLibrary.simpleMessage("Themes"),
    "agendaPageTitle": MessageLookupByLibrary.simpleMessage("Meeting Title"),
    "agendaPageTitleAppBar": MessageLookupByLibrary.simpleMessage("Agenda"),
    "authServiceEmailError": MessageLookupByLibrary.simpleMessage(
      "Email is invalid or already registered.",
    ),
    "authServiceInvalidCredentials": MessageLookupByLibrary.simpleMessage(
      "Invalid email or password.",
    ),
    "authServicePasswordError": MessageLookupByLibrary.simpleMessage(
      "Password is too weak or invalid.",
    ),
    "authServiceUnknownAccount": MessageLookupByLibrary.simpleMessage(
      "Account not found.",
    ),
    "authServiceUnknownError": MessageLookupByLibrary.simpleMessage(
      "An unknown error occurred during authentication.",
    ),
    "authServiceUsernameError": MessageLookupByLibrary.simpleMessage(
      "Username is invalid or already taken.",
    ),
    "selectDateCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "selectDateHourLabel": MessageLookupByLibrary.simpleMessage("HH"),
    "selectDateInvalidHourMinute": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid hour (0-23) and minute (0-59).",
    ),
    "selectDateMinuteLabel": MessageLookupByLibrary.simpleMessage("MM"),
    "selectDateOk": MessageLookupByLibrary.simpleMessage("OK"),
    "selectDateSelected": MessageLookupByLibrary.simpleMessage("Selected:"),
    "signupPageButtonSignup": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "signupPageLabelEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "signupPageLabelPassword": MessageLookupByLibrary.simpleMessage("Password"),
    "signupPageLabelUsername": MessageLookupByLibrary.simpleMessage("Username"),
    "signupPageLinkLogin": MessageLookupByLibrary.simpleMessage(
      "Already have an account? Login",
    ),
    "signupPageTitle": MessageLookupByLibrary.simpleMessage("Sign Up"),
  };
}
