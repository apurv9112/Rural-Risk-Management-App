import 'package:flutter/material.dart';

class ReportCell extends StatelessWidget {
  final String text;
  final double width;
  final bool bold;
  final TextAlign align;

  const ReportCell({
    super.key,
    required this.text,
    required this.width,
    this.bold = false,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 50),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.visible,
        softWrap: false,
        textAlign: align,
      ),
    );
  }
}
