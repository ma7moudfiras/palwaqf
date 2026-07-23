import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AwqafWaqfAssetsIntegrationIntakePage extends ConsumerWidget {
  const AwqafWaqfAssetsIntegrationIntakePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('استلام الأصول الوقفية')),
        body: const Center(
          child: Text('صفحة استلام الأصول الوقفية'),
        ),
        backgroundColor: theme.colorScheme.surface,
      ),
    );
  }
}

