import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/services/farmer_services.dart';
import 'package:rrm/services/pdf_service.dart';
import 'package:share_plus/share_plus.dart' show XFile, SharePlus, ShareParams;

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
      RenderRepaintBoundary boundary =
          reportKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 4);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      final pngBytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();

      final provider = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Image(provider, fit: pw.BoxFit.contain),
            );
          },
        ),
      );

      final directory = await getTemporaryDirectory();

      final file = File("${directory.path}/report.pdf");

      await file.writeAsBytes(await pdf.save());

      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
