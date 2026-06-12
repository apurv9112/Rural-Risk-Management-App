# SUBMISSION PATH AUDIT

## 1. CattleService (Tagging & Retagging)
- **Direct HTTP Calls**: Yes (`submitCattle` method).
- **MultipartRequest Usage**: Uses `http.MultipartRequest` targeting `/field-worker/save-cattle`.
- **Controller Entry Point**: `cattle_controller.dart` (`_submitCattle` at line 678). Handles `isClaimFlow = false`, `isClaimFlow = true`, and `retagging`.
- **Payload Construction Logic**: The controller builds a large `Map<String, dynamic> payload` containing primitives and `File` objects (e.g. `earTagImage`, `reTaggingVideo`, `conversionPdf`). It then passes it to `_cattleService.submitCattle` where it loops over the map and adds `http.MultipartFile` for all `File` objects.

## 2. ClaimService (Claim Flow)
- **Direct HTTP Calls**: Yes. Wait, the `CattleController` actually handles `isClaimFlow: true` and calls `_cattleService.submitCattle` using the SAME endpoint but passing `"leadType": "claim"`. So "Claim" submission (at least for cattle verification) uses `CattleService`.
- **MultipartRequest Usage**: Yes.
- **Controller Entry Point**: `cattle_controller.dart` (`saveclaim()`).
- **Payload Construction Logic**: Same map as tagging.

## 3. KycService (KYC Flow)
- **Direct HTTP Calls**: Yes.
- **MultipartRequest Usage**: Yes.
- **Controller Entry Point**: Assumed `kyc_controller.dart`.
- **Payload Construction Logic**: Appends `files[]` arrays dynamically to the multipart request.

## 4. CancelLeadService (Cancel Flow)
- **Direct HTTP Calls**: Yes.
- **MultipartRequest Usage**: Yes.
- **Controller Entry Point**: Assumed `cancel_lead_controller.dart`.
- **Payload Construction Logic**: Appends `cancellationImages[]` to the multipart request.

## Summary
All 5 workflows (Tagging, Retagging, Claim, KYC, Cancel Lead) currently bypass the offline queue system completely. They construct payloads locally and immediately block the UI to push to network via `http.MultipartRequest`.
