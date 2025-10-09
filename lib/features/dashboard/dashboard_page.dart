import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metanoia')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transform learning into understanding and reflection',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Wrap(spacing: 12, runSpacing: 12, children: [
              ElevatedButton(onPressed: ()=>context.go('/reflections'), child: const Text('Reflections')),
              ElevatedButton(onPressed: ()=>context.go('/cpd'), child: const Text('CPD')),
              ElevatedButton(onPressed: ()=>context.go('/export'), child: const Text('Export')),
            ])
          ],
        ),
      ),
    );
  }
}
