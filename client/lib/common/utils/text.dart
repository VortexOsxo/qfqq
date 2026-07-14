import 'package:flutter/material.dart';

Text listText(String text) {
  return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);
}