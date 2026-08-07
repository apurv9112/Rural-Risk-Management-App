import 'package:flutter/material.dart';
import 'package:rrm/pages/farmer_details/farmer_details_controller.dart';
import 'package:rrm/pages/farmer_details/widget/report/report_cell.dart';
import 'package:rrm/pages/farmer_details/widget/report/report_row.dart';
import 'package:rrm/pages/farmer_details/widget/report/report_title.dart';

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
    return Container(
      width: 794,
      constraints: const BoxConstraints(minHeight: 1123),
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const ReportTitle(title: "CLAIM REPORT"),

          const ReportRow(title1: "PERA-WET", value1: "DHARMESH PATEL"),

          const ReportRow(
            title1: "OWNER NAME",
            value1: "PATEL APURVKUMAR ANANTKUMAR",
          ),

          const ReportRow(
            title1: "VILLAGE",
            value1: "GABAT",
            title2: "TALUKA",
            value2: "GABAT",
          ),

          const ReportRow(
            title1: "DISTRICT",
            value1: "ARVALLI",
            title2: "STATE",
            value2: "GUJARAT",
          ),

          const ReportRow(title1: "MOBILE NO.", value1: "7568964521"),

          const ReportRow(title1: "BANK", value1: "HDFC ERGO"),

          const ReportRow(title1: "BRANCH", value1: "BAYAD"),

          const ReportRow(title1: "INSURANCE CO.", value1: "ICICI LOMBARD LTD"),

          const ReportRow(title1: "LAN NO.", value1: "123456"),

          const ReportRow(
            title1: "DEATH DATE",
            value1: "06-03-2026",
            title2: "DEATH TIME",
            value2: "06:50 PM",
          ),

          const ReportRow(
            title1: "ATTEND DATE",
            value1: "04-06-2026",
            title2: "ATTEND TIME",
            value2: "09:00 AM",
          ),

          const SizedBox(height: 24),

          Row(
            children: const [
              Expanded(
                flex: 3,
                child: ReportCell(
                  text: "TAG NO.",
                  width: 0,
                  bold: true,
                  align: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: ReportCell(
                  text: "SPECIES",
                  width: 0,
                  bold: true,
                  align: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 3,
                child: ReportCell(
                  text: "SUM INSURED",
                  width: 0,
                  bold: true,
                  align: TextAlign.center,
                ),
              ),
            ],
          ),

          Row(
            children: const [
              Expanded(
                flex: 3,
                child: ReportCell(
                  text: "3500012350",
                  width: 0,
                  align: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: ReportCell(
                  text: "BUFFALO",
                  width: 0,
                  align: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 3,
                child: ReportCell(
                  text: "60,000",
                  width: 0,
                  align: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
