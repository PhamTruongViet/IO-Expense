import 'package:flutter/material.dart';

class DetailInputScreen extends StatelessWidget {
  final TextEditingController _detailController = TextEditingController();

  DetailInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _detailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter detail',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _detailController.text);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
