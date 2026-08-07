import 'package:flutter/material.dart';

class CommonReportHeader extends StatelessWidget {
  final String title;

  const CommonReportHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const Divider(thickness: 2),

        const SizedBox(height: 20),
      ],
    );
  }
}
