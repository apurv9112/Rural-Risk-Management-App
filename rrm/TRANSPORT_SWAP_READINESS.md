# TRANSPORT SWAP READINESS AUDIT

## Phase 1 Readiness Inspection

### 1. `MediaTransportService` Interface Abstraction
- **Current Status**: All orchestration code (specifically `MediaSyncWorker`) relies exclusively on the abstract `MediaTransportService`. No internal component within the synchronization flow casts or relies on mock-specific methods.
- **Verdict**: **READY**. The abstraction holds up cleanly.

### 2. Dependency Resolution
- **Current Status**: 
  - `dependency_injection.dart` explicitly instantiates `MockMediaTransportService()` inline during DI setup.
  - `background_sync_manager.dart` explicitly instantiates `MockMediaTransportService()` inline when recreating the `GetIt` container inside the isolate.
- **Verdict**: **PARTIAL**. The concrete mock class is hardcoded in DI registration instead of resolving via an environment-based factory. A simple `bool isProd` toggle in `getIt` setup will resolve this.

### 3. Background Isolate Reconstruction Support
- **Current Status**: The isolate `callbackDispatcher()` safely reconstructs all singletons natively. It has zero UI dependencies, making it completely capable of injecting a `RealMediaTransportService` paired with an `EndpointProvider` and `MediaHttpClient`.
- **Verdict**: **READY**. 

## Gap Analysis for Swap
The primary gap is the `initUpload` method signature on the current `MediaTransportService`. It currently accepts `(String filePath, int totalSize)`. Production requires `(String checksum, int fileSize, String mimeType)`. 
Since we are restricted from modifying the queue schema in this phase, the `MediaSyncWorker` must calculate the `checksum` and `mimeType` natively from the `filePath` before passing it to the real transport service.

## Final Verdict
The architecture is **APPROVED** for swapping. The strict boundaries between DI and the orchestration loop allow us to swap the transport implementation seamlessly.
