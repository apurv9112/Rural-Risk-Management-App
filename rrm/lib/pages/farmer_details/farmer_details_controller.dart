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
  Map<String, dynamic> retaggingData = {};
  Map<String, dynamic> claimData = {};
  Map<String, dynamic> manualTaggingData = {};
  String dateOfDeath = "";
  String timeOfDeath = "";
  final reportCreatedAt = DateTime.now();

  bool isLoading = true;
  bool isReportShared = false;

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
    retaggingData = Map<String, dynamic>.from(args["retaggingData"] ?? {});

    claimData = Map<String, dynamic>.from(args["claimData"] ?? {});

    manualTaggingData = Map<String, dynamic>.from(
      args["manualTaggingData"] ?? {},
    );
    // ⭐ Claim death data
    dateOfDeath = args["dateOfDeath"] ?? "";
    timeOfDeath = args["timeOfDeath"] ?? "";

    debugPrint("========== REPORT DATA FLOW ==========");
    debugPrint("TAGGING DATA        : $taggingData");
    debugPrint("RETAGGING DATA      : $retaggingData");
    debugPrint("CLAIM DATA          : $claimData");
    debugPrint("MANUAL TAGGING DATA : $manualTaggingData");
    debugPrint("======================================");
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
      if (type.toLowerCase() == "retagging") {
        await _generateRetaggingPdf();
        return;
      }
      if (type.toLowerCase() == "claim") {
        await _generateClaimPdf();
        return;
      }
      final pdf = pw.Document();

      final owner = report["owner"] ?? {};
      final cattle = List<Map<String, dynamic>>.from(report["cattle"] ?? [])
          .where((item) {
            final tagNo = item["tagNo"]?.toString().trim() ?? "";
            return tagNo.isNotEmpty;
          })
          .toList();

      final leadData = taggingData;
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
                "PARA-VET",
                (appController.userName.value ?? "").toString().toUpperCase(),
                type.toLowerCase() == "tagging" ? "TAGGING DATE" : "DATE",
                _formatPdfDate(
                      leadData["createdAt"],
                    )?.toString().split("T").first ??
                    "",
              ),

              _pdfSingleRow(
                "OWNER NAME",
                (leadData["ownerName"] ?? owner["name"] ?? "")
                    .toString()
                    .toUpperCase(),
              ),

              _pdfDoubleRow(
                "VILLAGE",
                (leadData["village"] ?? owner["village"] ?? "")
                    .toString()
                    .toUpperCase(),
                "TALUKA",
                (leadData["taluko"] ?? owner["taluka"] ?? "")
                    .toString()
                    .toUpperCase(),
              ),

              _pdfDoubleRow(
                "DISTRICT",
                (leadData["district"] ?? owner["district"] ?? "")
                    .toString()
                    .toUpperCase(),
                "STATE",
                (leadData["state"] ?? owner["state"] ?? "")
                    .toString()
                    .toUpperCase(),
              ),

              _pdfDoubleRow(
                "BANK",
                (leadData["bankName"] ?? "").toString().toUpperCase(),
                "BRANCH",
                (leadData["branchOfBank"] ?? "").toString().toUpperCase(),
              ),

              _pdfDoubleRow(
                "LAN NO.",
                (leadData["loanAccountNo"] ?? owner["lanNumber"] ?? "")
                    .toString()
                    .toUpperCase(),
                "INSURANCE CO.",
                (leadData["insuranceCompanyName"] ?? "")
                    .toString()
                    .toUpperCase(),
              ),

              _pdfDoubleRow(
                "MOBILE NO.",
                (leadData["mobileNo"] ?? owner["mobile"] ?? "")
                    .toString()
                    .toUpperCase(),
                "TOTAL CATTLE",
                "${cattle.length}",
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

      final file = File(
        "${directory.path}/Tagging Report - PARA-VET - ${appController.userName.value}.pdf",
      );

      final pdfBytes = await pdf.save();

      await file.writeAsBytes(pdfBytes);

      debugPrint("PDF SAVED : ${file.path}");
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: "Pera-Wet - ${appController.userName.value}",
        ),
      );

      isReportShared = true;
      update();

      debugPrint("PDF SHARE COMPLETED");
      debugPrint("Share status: $isReportShared");

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

  /// Retagging PDF Generation ///

  Future<void> _generateRetaggingPdf() async {
    try {
      final pdf = pw.Document();

      final owner = report["owner"] ?? {};
      final cattle = List<Map<String, dynamic>>.from(report["cattle"] ?? []);

      final leadData = retaggingData;

      final cattleItem = cattle.isNotEmpty ? cattle.first : {};

      final taggingDate = _formatPdfDate(leadData["createdAt"]);

      final reTaggingDate = _formatPdfDate(leadData["dateOfReTagging"]);

      final oldTagNumber = leadData["oldTagNumber"] ?? "";

      final newTagNumber = leadData["newTagNumber"] ?? "";

      final species = cattleItem["species"] ?? leadData["species"] ?? "";

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(25),
          build: (context) {
            return pw.Column(
              children: [
                // TITLE
                pw.Container(
                  height: 55,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                  ),
                  child: pw.Text(
                    "RE-TAGGING REPORT",
                    style: pw.TextStyle(
                      color: PdfColor.fromInt(0xff93256d),
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                // PARA-VET
                _pdfSingleRow(
                  "PARA-VET",
                  (appController.userName.value ?? "").toString().toUpperCase(),
                ),

                // OWNER
                _pdfSingleRow(
                  "OWNER NAME",
                  (leadData["ownerName"] ?? owner["name"] ?? "")
                      .toString()
                      .toUpperCase(),
                ),

                // VILLAGE + TALUKA
                _pdfDoubleRow(
                  "VILLAGE",
                  (leadData["village"] ?? owner["village"] ?? "")
                      .toString()
                      .toUpperCase(),
                  "TALUKA",
                  (leadData["taluko"] ?? owner["taluka"] ?? "")
                      .toString()
                      .toUpperCase(),
                ),

                // DISTRICT + STATE
                _pdfDoubleRow(
                  "DISTRICT",
                  (leadData["district"] ?? owner["district"] ?? "")
                      .toString()
                      .toUpperCase(),
                  "STATE",
                  (leadData["state"] ?? owner["state"] ?? "")
                      .toString()
                      .toUpperCase(),
                ),

                // BANK
                _pdfSingleRow(
                  "BANK",
                  (leadData["bankName"] ?? "").toString().toUpperCase(),
                ),

                // BRANCH
                _pdfSingleRow(
                  "BRANCH",
                  (leadData["branchOfBank"] ?? "").toString().toUpperCase(),
                ),

                // INSURANCE
                _pdfSingleRow(
                  "INSURANCE CO.",
                  (leadData["insuranceCompanyName"] ?? "")
                      .toString()
                      .toUpperCase(),
                ),

                // LAN
                _pdfSingleRow(
                  "LAN NO.",
                  (leadData["loanAccountNo"] ?? owner["lanNumber"] ?? "")
                      .toString()
                      .toUpperCase(),
                ),

                // MOBILE
                _pdfSingleRow(
                  "MOBILE NO.",
                  (leadData["mobileNo"] ?? owner["mobile"] ?? "")
                      .toString()
                      .toUpperCase(),
                ),

                pw.SizedBox(height: 15),

                // RETAGGING TABLE
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(3),
                    3: const pw.FlexColumnWidth(3),
                    4: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        _pdfHeaderCell("TAGGING DATE"),
                        _pdfHeaderCell("OLD TAG NO."),
                        _pdfHeaderCell("RE-TAGGING DATE"),
                        _pdfHeaderCell("NEW TAG NO."),
                        _pdfHeaderCell("SPECIES"),
                      ],
                    ),

                    pw.TableRow(
                      children: [
                        _pdfCell2(taggingDate, bold: false, center: true),
                        _pdfCell2(oldTagNumber, bold: false, center: true),
                        _pdfCell2(reTaggingDate, bold: false, center: true),
                        _pdfCell2(newTagNumber, bold: false, center: true),
                        _pdfCell2(species, bold: false, center: true),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final directory = await getTemporaryDirectory();

      final file = File(
        "${directory.path}/Re-Tagging Report - PARA-VET - ${appController.userName.value}.pdf",
      );

      await file.writeAsBytes(await pdf.save());

      debugPrint("RETAGGING PDF SAVED : ${file.path}");

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: "Pera-Wet - ${appController.userName.value}",
        ),
      );

      isReportShared = true;
      update();

      debugPrint("PDF SHARE COMPLETED");
      debugPrint("Share status: $isReportShared");

      debugPrint("RETAGGING PDF CREATED SUCCESSFULLY");
    } catch (e) {
      debugPrint("RETAGGING PDF ERROR: $e");
    }
  }

  String _formatPdfDate(dynamic value) {
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

  pw.Widget _pdfHeaderCell(String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      alignment: pw.Alignment.center,
      child: pw.Text(
        value,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _pdfCell2(String value, {bool bold = true, bool center = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      alignment: center ? pw.Alignment.center : pw.Alignment.centerLeft,
      child: pw.Text(
        value,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _generateClaimPdf() async {
    try {
      final pdf = pw.Document();

      final owner = report["owner"] ?? {};

      final cattle = List<Map<String, dynamic>>.from(report["cattle"] ?? []);

      final leadData = claimData;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(25),
          build: (context) {
            return pw.Column(
              children: [
                // =========================
                // TITLE
                // =========================
                pw.Container(
                  height: 55,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                  ),
                  child: pw.Text(
                    "CLAIM REPORT",
                    style: pw.TextStyle(
                      color: PdfColor.fromInt(0xff93256d),
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                // =========================
                // PERA-WET
                // =========================
                _pdfSingleRow(
                  "PARA-VET",
                  (appController.userName.value ?? "").toString().toUpperCase(),
                ),

                // =========================
                // OWNER NAME
                // =========================
                _pdfSingleRow(
                  "OWNER NAME",
                  (leadData["ownerName"] ?? owner["name"] ?? "")
                      .toString()
                      .toUpperCase(),
                ),

                // =========================
                // VILLAGE + TALUKA
                // =========================
                _pdfDoubleRow(
                  "VILLAGE",
                  (leadData["village"] ?? owner["village"] ?? "")
                      .toString()
                      .toUpperCase(),
                  "TALUKA",
                  (leadData["taluko"] ?? owner["taluka"] ?? "")
                      .toString()
                      .toUpperCase(),
                ),

                // =========================
                // DISTRICT + STATE
                // =========================
                _pdfDoubleRow(
                  "DISTRICT",
                  (leadData["district"] ?? owner["district"] ?? "")
                      .toString()
                      .toUpperCase(),
                  "STATE",
                  (leadData["state"] ?? owner["state"] ?? "")
                      .toString()
                      .toUpperCase(),
                ),

                // =========================
                // MOBILE
                // =========================
                _pdfSingleRow(
                  "MOBILE NO.",
                  (leadData["mobileNo"] ?? owner["mobile"] ?? "")
                      .toString()
                      .toUpperCase(),
                ),

                // =========================
                // BANK
                // =========================
                _pdfSingleRow(
                  "BANK",
                  (leadData["bankName"] ?? "").toString().toUpperCase(),
                ),

                // =========================
                // BRANCH
                // =========================
                _pdfSingleRow(
                  "BRANCH",
                  (leadData["branchOfBank"] ?? "").toString().toUpperCase(),
                ),

                // =========================
                // INSURANCE
                // =========================
                _pdfSingleRow(
                  "INSURANCE CO.",
                  (leadData["insuranceCompanyName"] ?? "")
                      .toString()
                      .toUpperCase(),
                ),

                // =========================
                // LAN
                // =========================
                _pdfSingleRow(
                  "LAN NO.",
                  (leadData["loanAccountNo"] ?? owner["lanNumber"] ?? "")
                      .toString()
                      .toUpperCase(),
                ),

                // =========================
                // DEATH DATE + TIME
                // createdAt
                // =========================
                _pdfDoubleRow(
                  "DEATH DATE",
                  _formatPdfDate(dateOfDeath),
                  "DEATH TIME",
                  timeOfDeath,
                ),

                // =========================
                // ATTEND DATE + TIME
                // Cattle page data
                // =========================
                _pdfDoubleRow(
                  "ATTEND DATE",
                  _formatPdfDate(reportCreatedAt),
                  "ATTEND TIME",
                  _formatPdfTime(reportCreatedAt),
                ),

                pw.SizedBox(height: 15),

                // =========================
                // CLAIM TABLE
                // =========================
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        _pdfHeaderCell("TAG NO."),
                        _pdfHeaderCell("SPECIES"),
                        _pdfHeaderCell("SUM INSURED"),
                      ],
                    ),

                    ...List.generate(cattle.length, (index) {
                      final item = cattle[index];

                      return pw.TableRow(
                        children: [
                          _pdfCell2(
                            "${item["tagNo"] ?? ""}",
                            bold: false,
                            center: true,
                          ),
                          _pdfCell2(
                            "${item["species"] ?? ""}",
                            bold: false,
                            center: true,
                          ),
                          _pdfCell2(
                            "${item["sumInsured"] ?? ""}",
                            bold: false,
                            center: true,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // =========================
      // SAVE PDF
      // =========================
      final directory = await getTemporaryDirectory();

      final file = File(
        "${directory.path}/Claim Report - PARA-VET - ${appController.userName.value}.pdf",
      );

      await file.writeAsBytes(await pdf.save());

      debugPrint("CLAIM PDF SAVED : ${file.path}");

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: "Pera-Wet - ${appController.userName.value}",
        ),
      );

      isReportShared = true;
      update();

      debugPrint("PDF SHARE COMPLETED");
      debugPrint("Share status: $isReportShared");

      debugPrint("CLAIM PDF CREATED SUCCESSFULLY");
    } catch (e) {
      debugPrint("CLAIM PDF ERROR: $e");
    }
  }

  String _formatPdfTime(dynamic value) {
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
      return value.toString();
    }
  }
}
