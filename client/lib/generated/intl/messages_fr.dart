// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(date) => "Réunion le ${date}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "agendaPageActualName": MessageLookupByLibrary.simpleMessage(
      "Date de rédaction",
    ),
    "agendaPageAddParticipant": MessageLookupByLibrary.simpleMessage(
      "Ajouter un participant",
    ),
    "agendaPageAddTheme": MessageLookupByLibrary.simpleMessage(
      "Ajouter un thème",
    ),
    "agendaPageAnimatorLabel": MessageLookupByLibrary.simpleMessage(
      "Animateur",
    ),
    "agendaPageCancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "agendaPageGoals": MessageLookupByLibrary.simpleMessage(
      "Objectifs de la réunion",
    ),
    "agendaPageLocation": MessageLookupByLibrary.simpleMessage(
      "Lieu de la réunion",
    ),
    "agendaPageMeetingOn": m0,
    "agendaPageSaveAgenda": MessageLookupByLibrary.simpleMessage(
      "Enregistrer l\'ordre du jour",
    ),
    "agendaPageSectionMeetingDetails": MessageLookupByLibrary.simpleMessage(
      "Détails de la réunion",
    ),
    "agendaPageSectionPeople": MessageLookupByLibrary.simpleMessage(
      "Participants",
    ),
    "agendaPageSectionScheduleLocation": MessageLookupByLibrary.simpleMessage(
      "Horaire & Lieu",
    ),
    "agendaPageSectionThemes": MessageLookupByLibrary.simpleMessage("Thèmes"),
    "agendaPageTitle": MessageLookupByLibrary.simpleMessage(
      "Titre de la réunion",
    ),
    "agendaPageTitleAppBar": MessageLookupByLibrary.simpleMessage(
      "Ordre du jour",
    ),
    "authServiceEmailError": MessageLookupByLibrary.simpleMessage(
      "Email invalide ou déjà enregistré.",
    ),
    "authServiceInvalidCredentials": MessageLookupByLibrary.simpleMessage(
      "Email ou mot de passe invalide.",
    ),
    "authServicePasswordError": MessageLookupByLibrary.simpleMessage(
      "Mot de passe trop faible ou invalide.",
    ),
    "authServiceUnknownAccount": MessageLookupByLibrary.simpleMessage(
      "Compte introuvable.",
    ),
    "authServiceUnknownError": MessageLookupByLibrary.simpleMessage(
      "Une erreur inconnue est survenue lors de l\'authentification.",
    ),
    "authServiceUsernameError": MessageLookupByLibrary.simpleMessage(
      "Nom d\'utilisateur invalide ou déjà pris.",
    ),
    "selectDateCancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "selectDateHourLabel": MessageLookupByLibrary.simpleMessage("HH"),
    "selectDateInvalidHourMinute": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer une heure (0-23) et une minute (0-59) valides.",
    ),
    "selectDateMinuteLabel": MessageLookupByLibrary.simpleMessage("MM"),
    "selectDateOk": MessageLookupByLibrary.simpleMessage("OK"),
    "selectDateSelected": MessageLookupByLibrary.simpleMessage("Sélectionné :"),
    "signupPageButtonSignup": MessageLookupByLibrary.simpleMessage(
      "S\'inscrire",
    ),
    "signupPageLabelEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "signupPageLabelPassword": MessageLookupByLibrary.simpleMessage(
      "Mot de passe",
    ),
    "signupPageLabelUsername": MessageLookupByLibrary.simpleMessage(
      "Nom d\'utilisateur",
    ),
    "signupPageLinkLogin": MessageLookupByLibrary.simpleMessage(
      "Déjà un compte ? Se connecter",
    ),
    "signupPageTitle": MessageLookupByLibrary.simpleMessage("Inscription"),
  };
}
