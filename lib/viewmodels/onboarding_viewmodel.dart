import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:flutter/foundation.dart';

class OnboardingViewModel extends ChangeNotifier {
  int _currentStep = 0;
  int? _selectedAge;
  String? _selectedGender;
  bool _isLoading = false;

  int get currentStep => _currentStep;
  int? get selectedAge => _selectedAge;
  String? get selectedGender => _selectedGender;
  bool get isLoading => _isLoading;

  int get totalSteps => 2;

  void selectAge(int age) {
    _selectedAge = age;
    notifyListeners();
  }

  void selectGender(String? gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  Future<bool> completeOnboarding(AuthViewModel authVM) async {
    if (_selectedAge == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await authVM.completeLocalOnboarding(
        age: _selectedAge!,
        gender: _selectedGender,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
