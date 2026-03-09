import 'package:flutter/cupertino.dart';

typedef NavigationGuard = Future<bool> Function(BuildContext context);

NavigationGuard? activeNavigationGuard;
