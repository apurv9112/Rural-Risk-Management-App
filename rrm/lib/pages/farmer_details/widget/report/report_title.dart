import 'package:flutter/material.dart';

class ReportTitle extends StatelessWidget {
  final String title;

  const ReportTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all()),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xff8e2466),
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }
}
