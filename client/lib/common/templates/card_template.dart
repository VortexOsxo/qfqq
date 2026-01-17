import 'package:flutter/material.dart';

buildContentListCardTemplate(Widget cardContent) {
  return Card(
    margin: EdgeInsets.all(16),
    child: Padding(
      padding: EdgeInsets.only(top: 16, bottom: 16),
      child: cardContent,
    ),
  );
}
