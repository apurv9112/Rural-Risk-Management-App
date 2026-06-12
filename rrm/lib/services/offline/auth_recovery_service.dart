abstract class AuthRecoveryService {
  Future<bool> refreshToken();
}

class MockAuthRecoveryService implements AuthRecoveryService {
  bool failRefresh = false;

  @override
  Future<bool> refreshToken() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (failRefresh) {
      return false;
    }
    
    return true;
  }
}
