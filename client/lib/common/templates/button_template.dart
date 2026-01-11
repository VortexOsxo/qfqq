import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget buildNavButtonTemplate(
  BuildContext context,
  String text,
  String path, {
  Object? extra,
}) {
  return buildActionButtonTemplate(
    context,
    text,
    () => context.go(path, extra: extra),
  );
}

Widget buildActionButtonTemplate(
  BuildContext context,
  String text,
  Function() action,
) {
  return Padding(
    padding: EdgeInsets.all(10),
    child: ElevatedButton(
      onPressed: action,
      style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
      child: Text(text),
    ),
  );
}
