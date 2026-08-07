import 'package:flutter/material.dart';
import 'package:rrm/pages/farmer_details/farmer_details_controller.dart';

class TaggingReportWidget extends StatelessWidget {
  final Map<String, dynamic> report;
  final FarmerDetailsController controller;

  const TaggingReportWidget({
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

          _row(
            "PERA-WET",
            controller.appController.userName.value,
            "TAGGING DATE",
            "2026-08-01",
          ),

          _singleRow("OWNER NAME", owner["name"] ?? ""),

          _row(
            "VILLAGE",
            owner["village"] ?? "",
            "TALUKA",
            owner["village"] ?? "",
          ),

          _row(
            "DISTRICT",
            owner["district"] ?? "",
            "STATE",
            owner["state"] ?? "",
          ),

          _row("BANK", "HDFC ERGO", "BRANCH", "BAYAD"),

          _row(
            "LAN NO.",
            owner["lanNumber"] ?? "",
            "INSURANCE CO.",
            "ICICI LOMBARD LTD",
          ),

          _row(
            "MOBILE NO.",
            owner["mobile"] ?? "",
            "TOTAL CATTLE",
            "${report["totalCattle"] ?? 0}",
          ),

          const SizedBox(height: 20),

          Table(
            border: TableBorder.all(color: Colors.black),
            columnWidths: const {
              0: FixedColumnWidth(80),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(3),
            },
            children: [
              TableRow(
                children: [
                  _headerCell("SR.NO"),
                  _headerCell("TAG NO."),
                  _headerCell("SPECIES"),
                  _headerCell("SUM INSURED"),
                ],
              ),

              ...List.generate(cattle.length, (index) {
                final item = cattle[index];

                return TableRow(
                  children: [
                    _cell("${index + 1}"),
                    _cell(item["tagNo"] ?? ""),
                    _cell(item["species"] ?? ""),
                    _cell("${item["sumInsured"] ?? ""}"),
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
        "TAGGING REPORT",
        style: TextStyle(
          color: Color(0xff93256d),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _row(String label1, String value1, String label2, String value2) {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(3),
      },
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

  Widget _singleRow(String label, String value) {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(8)},
      children: [
        TableRow(children: [_cell(label, isBold: false), _cell(value)]),
      ],
    );
  }

  Widget _headerCell(String value) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _cell(String value, {bool isBold = true}) {
    return Container(
      padding: const EdgeInsets.all(10),
      alignment: Alignment.centerLeft,
      constraints: const BoxConstraints(minHeight: 50),
      child: Text(
        value,
        softWrap: true,
        style: TextStyle(
          fontSize: 18,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
