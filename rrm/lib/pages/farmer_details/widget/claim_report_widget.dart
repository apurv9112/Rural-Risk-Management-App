import 'package:flutter/material.dart';
import 'package:rrm/pages/farmer_details/farmer_details_controller.dart';

class ClaimReportWidget extends StatelessWidget {
  final Map<String, dynamic> report;
  final FarmerDetailsController controller;

  const ClaimReportWidget({
    super.key,
    required this.report,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final owner = report["owner"] ?? {};

    final cattle = List<Map<String, dynamic>>.from(report["cattle"] ?? []);

    // CLAIM FLOW DATA
    final leadData = controller.claimData;

    return Container(
      width: 794,
      constraints: const BoxConstraints(minHeight: 1123),
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _title(),

          _singleRow(
            "PARA-VET",
            (controller.appController.userName.value ?? "")
                .toString()
                .toUpperCase(),
            context,
          ),

          _singleRow(
            "OWNER NAME",
            (leadData["ownerName"] ?? owner["name"] ?? "")
                .toString()
                .toUpperCase(),
            context,
          ),

          _doubleRow(
            "VILLAGE",
            (leadData["village"] ?? owner["village"] ?? "")
                .toString()
                .toUpperCase(),
            "TALUKA",
            (leadData["taluko"] ?? owner["taluka"] ?? "")
                .toString()
                .toUpperCase(),
            context,
          ),

          _doubleRow(
            "DISTRICT",
            (leadData["district"] ?? owner["district"] ?? "")
                .toString()
                .toUpperCase(),
            "STATE",
            (leadData["state"] ?? owner["state"] ?? "")
                .toString()
                .toUpperCase(),
            context,
          ),

          _singleRow(
            "MOBILE NO.",
            (leadData["mobileNo"] ?? owner["mobile"] ?? "")
                .toString()
                .toUpperCase(),
            context,
          ),

          _singleRow(
            "BANK",
            (leadData["bankName"] ?? "").toString().toUpperCase(),
            context,
          ),

          _singleRow(
            "BRANCH",
            (leadData["branchOfBank"] ?? "").toString().toUpperCase(),
            context,
          ),

          _singleRow(
            "INSURANCE CO.",
            (leadData["insuranceCompanyName"] ?? "").toString().toUpperCase(),
            context,
          ),

          _singleRow(
            "LAN NO.",
            (leadData["loanAccountNo"] ?? owner["lanNumber"] ?? "")
                .toString()
                .toUpperCase(),
            context,
          ),

          _doubleRow(
            "DEATH DATE",
            _formatDate(controller.dateOfDeath),
            "DEATH TIME",
            controller.timeOfDeath,
            context,
          ),

          _doubleRow(
            "ATTEND DATE",
            _formatDate(controller.reportCreatedAt),
            "ATTEND TIME",
            _formatTime(controller.reportCreatedAt),
            context,
          ),

          const SizedBox(height: 30),

          Table(
            border: TableBorder.all(color: Colors.black),
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                children: [
                  _headerCell("TAG NO.", context),
                  _headerCell("SPECIES", context),
                  _headerCell("SUM INSURED", context),
                ],
              ),

              ...List.generate(cattle.length, (index) {
                final item = cattle[index];

                return TableRow(
                  children: [
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

  Widget _title() {
    return Container(
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all()),
      child: const Text(
        "CLAIM REPORT",
        style: TextStyle(
          color: Color(0xff93256d),
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _singleRow(String label, String value, BuildContext context) {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            _cell(label, context, isBold: false, isLeft: true),
            _cell(value, context, isLeft: true, isBold: true),
          ],
        ),
      ],
    );
  }

  Widget _doubleRow(
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
            _cell(value1, context, isLeft: true, isBold: true),
            _cell(label2, context, isBold: false, isLeft: true),
            _cell(value2, context, isLeft: true, isBold: true),
          ],
        ),
      ],
    );
  }

  String _formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return "";
    }

    try {
      final date = DateTime.parse(value.toString());

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return "$day-$month-$year";
    } catch (e) {
      return value.toString();
    }
  }

  Widget _headerCell(String value, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      constraints: const BoxConstraints(minHeight: 55),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _cell(
    String value,
    BuildContext context, {
    bool isBold = false,
    bool isLeft = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: isLeft ? Alignment.centerLeft : Alignment.center,
      constraints: const BoxConstraints(minHeight: 50),
      child: Text(
        value,
        textAlign: isLeft ? TextAlign.left : TextAlign.center,
        softWrap: true,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  String _formatTime(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return "";
    }

    try {
      final date = DateTime.parse(value.toString()).toLocal();

      int hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');

      final period = hour >= 12 ? "PM" : "AM";

      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }

      return "${hour.toString().padLeft(2, '0')}:$minute $period";
    } catch (e) {
      return "";
    }
  }
}
