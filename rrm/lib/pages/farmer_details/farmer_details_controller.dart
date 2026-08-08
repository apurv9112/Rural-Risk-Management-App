import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rrm/controller.dart';
import 'package:rrm/services/farmer_services.dart';
import 'package:rrm/services/pdf_service.dart';
import 'package:share_plus/share_plus.dart';

class FarmerDetailsController extends GetxController {
  final FarmerReportService _service = FarmerReportService();
  AppController appController = Get.find();
  final PdfService pdfService = PdfService();
  final GlobalKey reportKey = GlobalKey();

  Map<String, dynamic> report = {};
  Map<String, dynamic> taggingData = {};
  Map<String, dynamic> kycData = {};
  Map<String, dynamic> cattleData = {};
  Map<String, dynamic> signatureData = {};

  bool isLoading = true;

  String type = "";

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    debugPrint("Arguments : $args");

    getReport(leadId: args["leadId"], leadType: args["leadType"]);

    type = args["leadType"] ?? "";

    taggingData = Map<String, dynamic>.from(args["taggingData"] ?? {});

    kycData = Map<String, dynamic>.from(args["kycData"] ?? {});

    cattleData = Map<String, dynamic>.from(args["cattleData"] ?? {});

    signatureData = Map<String, dynamic>.from(args["signatureData"] ?? {});
  }

  Future<void> getReport({
    required String leadId,
    required String leadType,
  }) async {
    try {
      report = await _service.getReport(leadId: leadId, leadType: leadType);
    } catch (e) {
      debugPrint("Farmer Report Error: $e");
      report = {};
    } finally {
      isLoading = false;
      update();
    }
  }

  String getTemplatePath() {
    switch (type.toLowerCase()) {
      case "claim":
        return "assets/excel/CLAIM_REPORT.xlsx";

      case "retagging":
        return "assets/excel/RE-TAGGING_REPORT.xlsx";

      default:
        return "assets/excel/TAGGING_REPORT.xlsx";
    }
  }

  Future<void> generatePdf() async {
    try {
      final pdf = pw.Document();

      final owner = report["owner"] ?? {};

      final cattle = List<Map<String, dynamic>>.from(report["cattle"] ?? []);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(25),

          build: (context) {
            return [
              pw.Container(
                height: 55,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                ),
                child: pw.Text(
                  type.toUpperCase() == "RETAGGING"
                      ? "RE-TAGGING REPORT"
                      : type.toUpperCase() == "CLAIM"
                      ? "CLAIM REPORT"
                      : "TAGGING REPORT",
                  style: pw.TextStyle(
                    color: PdfColor.fromInt(0xff93256d),
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              _pdfDoubleRow(
                "PERA-WET",
                appController.userName.value,
                type.toLowerCase() == "tagging" ? "TAGGING DATE" : "DATE",
                "",
              ),

              _pdfSingleRow("OWNER NAME", owner["name"] ?? ""),

              _pdfDoubleRow(
                "VILLAGE",
                owner["village"] ?? "",
                "TALUKA",
                owner["taluka"] ?? "",
              ),

              _pdfDoubleRow(
                "DISTRICT",
                owner["district"] ?? "",
                "STATE",
                owner["state"] ?? "",
              ),

              _pdfDoubleRow("BANK", "", "BRANCH", ""),

              _pdfDoubleRow(
                "LAN NO.",
                owner["lanNumber"] ?? "",
                "INSURANCE CO.",
                "",
              ),

              _pdfDoubleRow(
                "MOBILE NO.",
                owner["mobile"] ?? "",
                "TOTAL CATTLE",
                "${report["totalCattle"] ?? 0}",
              ),

              pw.SizedBox(height: 15),

              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                columnWidths: {
                  0: const pw.FixedColumnWidth(45),
                  1: const pw.FixedColumnWidth(150),
                  2: const pw.FixedColumnWidth(110),
                  3: const pw.FixedColumnWidth(120),
                },
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.white,
                ),
                headerStyle: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 8,
                ),
                cellAlignment: pw.Alignment.center,
                headerAlignment: pw.Alignment.center,
                headers: ["SR.NO", "TAG NO.", "SPECIES", "SUM INSURED"],
                data: cattle.map((item) {
                  return [
                    "${item["srNo"] ?? ""}",
                    "${item["tagNo"] ?? ""}",
                    "${item["species"] ?? ""}",
                    "${item["sumInsured"] ?? ""}",
                  ];
                }).toList(),
              ),
            ];
          },
        ),
      );
      final directory = await getTemporaryDirectory();

      final file = File("${directory.path}/farmer_report.pdf");

      final pdfBytes = await pdf.save();

      await file.writeAsBytes(pdfBytes);

      debugPrint("PDF SAVED : ${file.path}");
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: "Pera-Wet - ${appController.userName.value}",
        ),
      );

      debugPrint("PDF CREATED SUCCESSFULLY");
    } catch (e) {
      debugPrint("PDF ERROR: $e");
    }
  }

  pw.Widget _pdfSingleRow(String label, String value) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(100),
        1: const pw.FlexColumnWidth(),
      },
      children: [
        pw.TableRow(children: [_pdfCell(label, bold: false), _pdfCell(value)]),
      ],
    );
  }

  pw.Widget _pdfDoubleRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(100),
        1: const pw.FlexColumnWidth(),
        2: const pw.FixedColumnWidth(100),
        3: const pw.FlexColumnWidth(),
      },
      children: [
        pw.TableRow(
          children: [
            _pdfCell(label1, bold: false),
            _pdfCell(value1),
            _pdfCell(label2, bold: false),
            _pdfCell(value2),
          ],
        ),
      ],
    );
  }

  pw.Widget _pdfCell(String value, {bool bold = true}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
