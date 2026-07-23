import 'package:flutter/material.dart';

class PwfCrossSystemIntegrationPage extends StatelessWidget {
  const PwfCrossSystemIntegrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('عقود الربط بين الأنظمة')),
        backgroundColor: theme.colorScheme.surface,
        body: const Center(
          child: Text('صفحة عقود الربط بين الأنظمة'),
        ),
      ),
    );
  }
}

