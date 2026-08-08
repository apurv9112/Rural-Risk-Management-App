import 'package:flutter/material.dart';
import 'package:rrm/pages/farmer_details/farmer_details_controller.dart';
import 'package:rrm/utils/responsive.dart';

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
      width: wp(129),
      constraints: BoxConstraints(minHeight: hp(100)),
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _title(context),

          _row(
            "PERA-WET",
            controller.appController.userName.value,
            "TAGGING DATE",
            "2026-08-01",
            context,
          ),

          _singleRow("OWNER NAME", owner["name"] ?? "", context),

          _row(
            "VILLAGE",
            owner["village"] ?? "",
            "TALUKA",
            owner["taluka"] ?? "",
            context,
          ),

          _row(
            "DISTRICT",
            owner["district"] ?? "",
            "STATE",
            owner["state"] ?? "",
            context,
          ),

          _row("BANK", "HDFC ERGO", "BRANCH", "BAYAD", context),

          _row(
            "LAN NO.",
            owner["lanNumber"] ?? "",
            "INSURANCE CO.",
            "ICICI LOMBARD LTD",
            context,
          ),

          _row(
            "MOBILE NO.",
            owner["mobile"] ?? "",
            "TOTAL CATTLE",
            "${report["totalCattle"] ?? 0}",
            context,
          ),

          SizedBox(height: hp(2)),

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
                  _headerCell("SR.NO", context),
                  _headerCell("TAG NO.", context),
                  _headerCell("SPECIES", context),
                  _headerCell("SUM INSURED", context),
                ],
              ),

              ...List.generate(cattle.length, (index) {
                final item = cattle[index];

                return TableRow(
                  children: [
                    _cell("${index + 1}", context),
                    _cell(item["tagNo"] ?? "", context),
                    _cell(item["species"] ?? "", context),
                    _cell("${item["sumInsured"] ?? ""}", context),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Container(
      height: hp(5),
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all()),
      child: Text(
        "TAGGING REPORT",
        style: TextStyle(
          color: Color(0xff93256d),
          fontSize: dp(context, 24),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _row(
    String label1,
    String value1,
    String label2,
    String value2,
    BuildContext context,
  ) {
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
            _cell(label1, context, isBold: false, isLeft: true),
            _cell(value1, context, isLeft: true),
            _cell(label2, context, isBold: false, isLeft: true),
            _cell(value2, context, isLeft: true),
          ],
        ),
      ],
    );
  }

  Widget _singleRow(String label, String value, BuildContext context) {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(8)},
      children: [
        TableRow(
          children: [
            _cell(label, context, isBold: false, isLeft: true),
            _cell(value, context, isLeft: true),
          ],
        ),
      ],
    );
  }

  Widget _headerCell(String value, BuildContext context) {
    return Container(
      height: hp(5),
      alignment: Alignment.center,
      child: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: dp(context, 12),
        ),
      ),
    );
  }

  Widget _cell(
    String value,
    BuildContext context, {
    bool isBold = true,
    bool isLeft = false,
  }) {
    return Container(
      padding: EdgeInsets.all(8),
      alignment: Alignment.centerLeft,
      constraints: BoxConstraints(minHeight: hp(5)),
      child: isLeft
          ? Text(
              value,
              softWrap: true,
              style: TextStyle(
                fontSize: dp(context, 10),
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            )
          : Center(
              child: Text(
                value,
                softWrap: true,
                style: TextStyle(
                  fontSize: dp(context, 10),
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
    );
  }
}
