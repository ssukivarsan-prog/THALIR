import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import 'mock_data_generator.dart';

class AuthService extends ChangeNotifier {
  fb_auth.FirebaseAuth? _firebaseAuth;
  AppUser? _currentUser;
  bool _useMockMode = true;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isMockMode => _useMockMode;

  AuthService() {
    _initAuthListener();
  }

  void _initAuthListener() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firebaseAuth = fb_auth.FirebaseAuth.instance;
        _firebaseAuth?.authStateChanges().listen((fb_auth.User? user) {
          if (user != null) {
            _useMockMode = false;
            _currentUser = AppUser(
              userId: user.uid,
              role: 'principal',
              schoolId: MockDataGenerator.demoSchoolId,
              name: user.displayName ?? 'Principal Admin',
              email: user.email ?? 'principal@school.edu',
            );
            notifyListeners();
          }
        });
      } else {
        _useMockMode = true;
      }
    } catch (e) {
      debugPrint("Firebase Auth initialization notice (using Mock Mode): $e");
      _useMockMode = true;
    }
  }

  Future<bool> loginWithEmailPassword(String email, String password) async {
    return signInWithEmailAndPassword(email, password);
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      if (!_useMockMode && _firebaseAuth != null) {
        await _firebaseAuth!.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return true;
      }
    } catch (e) {
      debugPrint("Firebase login failed, falling back to demo auth: $e");
    }

    _useMockMode = true;
    if (email.contains('ceo') || email.contains('muni')) {
      _currentUser = MockDataGenerator.getDemoMunicipalityHead();
    } else {
      _currentUser = MockDataGenerator.getDemoHeadmaster();
    }
    notifyListeners();
    return true;
  }

  Future<bool> signInAsHeadmaster() async {
    _useMockMode = true;
    _currentUser = MockDataGenerator.getDemoHeadmaster();
    notifyListeners();
    return true;
  }

  Future<bool> signInAsMunicipalityHead() async {
    _useMockMode = true;
    _currentUser = MockDataGenerator.getDemoMunicipalityHead();
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    try {
      if (!_useMockMode && _firebaseAuth != null) {
        await _firebaseAuth!.signOut();
      }
    } catch (e) {
      debugPrint("Firebase signOut error: $e");
    }
    _currentUser = null;
    notifyListeners();
  }
}
