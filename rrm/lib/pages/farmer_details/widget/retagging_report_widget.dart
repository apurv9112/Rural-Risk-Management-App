import 'package:flutter/material.dart';
import 'package:rrm/pages/farmer_details/farmer_details_controller.dart';

class RetaggingReportWidget extends StatelessWidget {
  final Map<String, dynamic> report;
  final FarmerDetailsController controller;

  const RetaggingReportWidget({
    super.key,
    required this.report,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final owner = report["owner"] ?? {};
    final cattle = List<Map<String, dynamic>>.from(report["cattle"] ?? []);

    return Container(
      width: 794,
      constraints: const BoxConstraints(minHeight: 1123),
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _title(),

          _singleRow("PERA-WET", controller.appController.userName.value),

          _singleRow("OWNER NAME", owner["name"] ?? ""),

          _doubleRow(
            "VILLAGE",
            owner["village"] ?? "",
            "TALUKA",
            owner["village"] ?? "",
          ),

          _doubleRow(
            "DISTRICT",
            owner["district"] ?? "",
            "STATE",
            owner["state"] ?? "",
          ),

          _singleRow("BANK", "HDFC ERGO"),

          _singleRow("BRANCH", "BAYAD"),

          _singleRow("INSURANCE CO.", "ICICI LOMBARD LTD"),

          _singleRow("LAN NO.", owner["lanNumber"] ?? ""),

          _singleRow("MOBILE NO.", owner["mobile"] ?? ""),

          const SizedBox(height: 30),

          Table(
            border: TableBorder.all(),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(3),
              4: FlexColumnWidth(3),
            },
            children: [
              TableRow(
                children: [
                  _header("TAGGING DATE"),
                  _header("OLD TAG NO."),
                  _header("RE-TAGGING DATE"),
                  _header("NEW TAG NO."),
                  _header("SPECIES"),
                ],
              ),

              ...List.generate(cattle.length, (index) {
                final item = cattle[index];

                return TableRow(
                  children: [
                    _cell("10-08-2025"),
                    _cell(item["tagNo"] ?? ""),
                    _cell("01-08-2026"),
                    _cell(item["tagNo"] ?? ""),
                    _cell(item["species"] ?? ""),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return Container(
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all()),
      child: const Text(
        "RE-TAGGING REPORT",
        style: TextStyle(
          color: Color(0xff93256d),
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _singleRow(String label, String value) {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(children: [_cell(label, isBold: false), _cell(value)]),
      ],
    );
  }

  Widget _doubleRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            _cell(label1, isBold: false),
            _cell(value1),
            _cell(label2, isBold: false),
            _cell(value2),
          ],
        ),
      ],
    );
  }

  Widget _header(String value) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _cell(String value, {bool isBold = true}) {
    return Container(
      padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(minHeight: 50),
      child: Text(
        value,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
