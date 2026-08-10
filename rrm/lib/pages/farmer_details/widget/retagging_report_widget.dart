import 'package:flutter/material.dart';
import 'package:rrm/pages/farmer_details/farmer_details_controller.dart';
import 'package:rrm/utils/responsive.dart';

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

    // final cattle = List<Map<String, dynamic>>.from(report["cattle"] ?? []);
    final leadData = controller.retaggingData;
    final retagging = leadData;

    debugPrint("========== RETAGGING UI DATA ==========");
    debugPrint("LEAD DATA : ${controller.taggingData}");
    debugPrint("REPORT DATA : ${controller.report}");
    debugPrint("========================================");

    return Container(
      width: wp(129),
      constraints: BoxConstraints(minHeight: hp(100)),
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _title(context),

          _singleRow(
            "PERA-WET",
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
            (leadData["taluko"] ?? "").toString().toUpperCase(),
            context,
          ),

          _doubleRow(
            "DISTRICT",
            (leadData["district"] ?? "").toString().toUpperCase(),
            "STATE",
            (leadData["state"] ?? "").toString().toUpperCase(),
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

          _singleRow(
            "MOBILE NO.",
            (leadData["mobileNo"] ?? owner["mobile"] ?? "")
                .toString()
                .toUpperCase(),
            context,
          ),

          SizedBox(height: hp(2)),

          Table(
            border: TableBorder.all(color: Colors.black),

            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(3),
              3: FlexColumnWidth(3),
              4: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                children: [
                  _headerCell("TAGGING DATE", context),
                  _headerCell("OLD TAG NO.", context),
                  _headerCell("RE-TAGGING DATE", context),
                  _headerCell("NEW TAG NO.", context),
                  _headerCell("SPECIES", context),
                ],
              ),

              TableRow(
                children: [
                  _cell(_formatDate(retagging["createdAt"]), context),
                  _cell(retagging["oldTagNumber"] ?? "", context),
                  _cell(_formatDate(retagging["dateOfReTagging"]), context),
                  _cell(retagging["newTagNumber"] ?? "", context),
                  _cell(retagging["species"] ?? "", context),
                ],
              ),
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
        "RE-TAGGING REPORT",
        style: TextStyle(
          color: Color(0xff93256d),
          fontSize: dp(context, 24),
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
            _cell(value, context, isLeft: true),
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
      height: hp(5),
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      constraints: BoxConstraints(minHeight: hp(5)),
      child: Text(
        value,
        textAlign: TextAlign.center,
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
    bool isBold = false,
    bool isLeft = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      // alignment: Alignment.center,
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
