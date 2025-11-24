import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/controller.dart';

class DatadisplayController extends GetxController {
  String? retagging = "retagging";
  AppController appController = Get.find();
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController searchcontroller = TextEditingController();

  List<Map<String, String>> textList = [
    {
      "name": "Patel Apurv Anantbhai",
      "mobile": "7572855882",
      "village": "Gabat",
      "taluko": "Bayad",
      "dist": "Aravalli",
      "bank": "SBI",
      "branch": "Bayad",
      "loan_a/c_no": "45822368852",
      "Insurance": "TATA AIG",
      "address":
          "B-TF-7, Block - B, Third Floor, Signet Plaza Kunal Char Rasta Gotri Road Samta, Gotri Vadodara, Gujarat 390021 India",
    },
    {
      "name": "Patel Harsh Vikrambhai",
      "mobile": "9876543210",
      "village": "Hathipura",
      "taluko": "Bayad",
      "dist": "Aravalli",
      "bank": "SBI",
      "branch": "Bayad",
      "loan_a/c_no": "45822368852",
      "Insurance": "New India",
      "address":
          "B-TF-7, Block - B, Third Floor, Signet Plaza Kunal Char Rasta Gotri Road Samta, Gotri Vadodara, Gujarat 390021 India",
    },
    {
      "name": "Patel Apurv Anantbhai",
      "mobile": "7572855882",
      "village": "Gabat",
      "taluko": "Bayad",
      "dist": "Aravalli",
      "bank": "SBI",
      "branch": "Bayad",
      "loan_a/c_no": "45822368852",
      "Insurance": "TATA AIG",
      "address":
          "B-TF-7, Block - B, Third Floor, Signet Plaza Kunal Char Rasta Gotri Road Samta, Gotri Vadodara, Gujarat 390021 India",
    },
    {
      "name": "Patel Harsh Vikrambhai",
      "mobile": "9876543210",
      "village": "Hathipura",
      "taluko": "Bayad",
      "dist": "Aravalli",
      "bank": "SBI",
      "branch": "Bayad",
      "loan_a/c_no": "45822368852",
      "Insurance": "New India",
      "address":
          "B-TF-7, Block - B, Third Floor, Signet Plaza Kunal Char Rasta Gotri Road Samta, Gotri Vadodara, Gujarat 390021 India",
    },
    {
      "name": "Patel Apurv Anantbhai",
      "mobile": "7572855882",
      "village": "Gabat",
      "taluko": "Bayad",
      "dist": "Aravalli",
      "bank": "SBI",
      "branch": "Bayad",
      "loan_a/c_no": "45822368852",
      "Insurance": "TATA AIG",
      "address":
          "B-TF-7, Block - B, Third Floor, Signet Plaza Kunal Char Rasta Gotri Road Samta, Gotri Vadodara, Gujarat 390021 India",
    },
    {
      "name": "Patel Harsh Vikrambhai",
      "mobile": "9876543210",
      "village": "Hathipura",
      "taluko": "Bayad",
      "dist": "Aravalli",
      "bank": "SBI",
      "branch": "Bayad",
      "loan_a/c_no": "45822368852",
      "Insurance": "New India",
      "address":
          "B-TF-7, Block - B, Third Floor, Signet Plaza Kunal Char Rasta Gotri Road Samta, Gotri Vadodara, Gujarat 390021 India",
    },
    {
      "name": "Patel Apurv Anantbhai",
      "mobile": "7572855882",
      "village": "Gabat",
      "taluko": "Bayad",
      "dist": "Aravalli",
      "bank": "SBI",
      "branch": "Bayad",
      "loan_a/c_no": "45822368852",
      "Insurance": "TATA AIG",
      "address":
          "B-TF-7, Block - B, Third Floor, Signet Plaza Kunal Char Rasta Gotri Road Samta, Gotri Vadodara, Gujarat 390021 India",
    },
    {
      "name": "Patel Harsh Vikrambhai",
      "mobile": "9876543210",
      "village": "Hathipura",
      "taluko": "Bayad",
      "dist": "Aravalli",
      "bank": "SBI",
      "branch": "Bayad",
      "loan_a/c_no": "45822368852",
      "Insurance": "New India",
      "address":
          "B-TF-7, Block - B, Third Floor, Signet Plaza Kunal Char Rasta Gotri Road Samta, Gotri Vadodara, Gujarat 390021 India",
    },
    {
      "name": "Patel Apurv Anantbhai",
      "mobile": "7572855882",
      "village": "Gabat",
      "taluko": "Bayad",
      "dist": "Aravalli",
      "bank": "SBI",
      "branch": "Bayad",
      "loan_a/c_no": "45822368852",
      "Insurance": "TATA AIG",
      "address":
          "B-TF-7, Block - B, Third Floor, Signet Plaza Kunal Char Rasta Gotri Road Samta, Gotri Vadodara, Gujarat 390021 India",
    },
    {
      "name": "Patel Harsh Vikrambhai",
      "mobile": "9876543210",
      "village": "Hathipura",
      "taluko": "Bayad",
      "dist": "Aravalli",
      "bank": "SBI",
      "branch": "Bayad",
      "loan_a/c_no": "45822368852",
      "Insurance": "New India",
      "address":
          "B-TF-7, Block - B, Third Floor, Signet Plaza Kunal Char Rasta Gotri Road Samta, Gotri Vadodara, Gujarat 390021 India",
    },
    {
      "name": "Patel Apurv Anantbhai",
      "mobile": "7572855882",
      "village": "Gabat",
      "taluko": "Bayad",
      "dist": "Aravalli",
      "bank": "SBI",
      "branch": "Bayad",
      "loan_a/c_no": "45822368852",
      "Insurance": "TATA AIG",
      "address":
          "B-TF-7, Block - B, Third Floor, Signet Plaza Kunal Char Rasta Gotri Road Samta, Gotri Vadodara, Gujarat 390021 India",
    },
    {
      "name": "Patel Harsh Vikrambhai",
      "mobile": "9876543210",
      "village": "Hathipura",
      "taluko": "Bayad",
      "dist": "Aravalli",
      "bank": "SBI",
      "branch": "Bayad",
      "loan_a/c_no": "45822368852",
      "Insurance": "New India",
      "address":
          "B-TF-7, Block - B, Third Floor, Signet Plaza Kunal Char Rasta Gotri Road Samta, Gotri Vadodara, Gujarat 390021 India",
    },
  ];
}
