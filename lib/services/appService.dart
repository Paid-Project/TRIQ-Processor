class AppConfigService {
  static final AppConfigService _instance = AppConfigService._internal();

  factory AppConfigService() => _instance;

  AppConfigService._internal();

  String countryIso = 'IN'; // default
}

