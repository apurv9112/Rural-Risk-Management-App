import 'package:flutter/material.dart';
import 'report_cell.dart';

class ReportRow extends StatelessWidget {
  final String title1;
  final String value1;
  final String title2;
  final String value2;

  const ReportRow({
    super.key,
    required this.title1,
    required this.value1,
    this.title2 = "",
    this.value2 = "",
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ReportCell(text: title1, width: 130),

        Expanded(child: ReportCell(text: value1, width: 0, bold: true)),

        if (title2.isNotEmpty) ReportCell(text: title2, width: 130),

        if (title2.isNotEmpty)
          Expanded(child: ReportCell(text: value2, width: 0, bold: true)),
      ],
    );
  }
}
