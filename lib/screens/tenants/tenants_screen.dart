import 'package:flutter/material.dart';

class TenantsScreen extends StatelessWidget {
  const TenantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Penyewa'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Fitur Kelola Penyewa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Fitur ini sedang dalam pengembangan. '
                      'Provider sudah tersedia di providers/tenant_provider.dart',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('Info Pengembangan'),
            ),
          ],
        ),
      ),
    );
  }
}