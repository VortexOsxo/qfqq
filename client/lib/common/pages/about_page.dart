import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'About'),
      body: const Center(child: Text('About Page')),
    );
  }
}