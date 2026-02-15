import 'package:manager/core/storage/storage.dart';
import 'package:stacked/stacked.dart';

class UserService with ListenableServiceMixin{
  final ReactiveValue<String> _selectedLanguage = ReactiveValue<String>(getSelectedLanguage().isNotEmpty?getSelectedLanguage():'English');

  String get  selectedLanguage => _selectedLanguage.value;


  updateSelectedLanguage(String languageCode){
    _selectedLanguage.value = languageCode;
    notifyListeners();
  }
}