import 'package:flutter/material.dart';

Text listText(String text, {int maxLines = 1}) {
  return Text(text, maxLines: maxLines, overflow: TextOverflow.ellipsis);
}