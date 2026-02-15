import 'package:intl_phone_field/countries.dart';

/// Utility class to work with country data from the intl_phone_field package
class CountryHelper {
  /// Get a country by its ISO 2-letter code (e.g., "US", "IN", "AF")
  static Country? getCountryByCode(String code) {
    final countryCode = code.toUpperCase();
    try {
      return countries.firstWhere((country) => country.code == countryCode);
    } catch (_) {
      return null;
    }
  }

  String getCountryFlagFromDialCode(String? countryCode) {
    if (countryCode == null || countryCode.isEmpty) {
      return '🏳️'; // Default flag for unknown
    }

    final country = getCountryByDialCode(countryCode);
    return country?.flag ?? '🏳️';
  }

  /// Get a country by its dial code (e.g., "1", "91", "93")
  /// The dialCode parameter can include the + prefix or not
  static Country? getCountryByDialCode(String dialCode) {
    final code = dialCode.startsWith('+') ? dialCode.substring(1) : dialCode;
    try {
      return countries.firstWhere((country) => country.dialCode == code);
    } catch (_) {
      return null;
    }
  }

  /// Get a list of all countries that have a specific dial code
  /// This is useful because some dial codes are shared by multiple countries
  static List<Country> getCountriesByDialCode(String dialCode) {
    final code = dialCode.startsWith('+') ? dialCode.substring(1) : dialCode;
    return countries.where((country) => country.dialCode == code).toList();
  }

  /// Get a country name in a specific language
  /// Falls back to English name if translation not available
  static String getLocalizedCountryName(Country country, String languageCode) {
    return country.localizedName(languageCode) ?? country.name;
  }

  /// Format a full phone number with country code
  /// Example: formatPhoneNumber("1234567890", "US") returns "+1 1234567890"
  static String formatPhoneNumber(String phoneNumber, String countryCode) {
    final country = getCountryByCode(countryCode);
    if (country == null) return phoneNumber;

    return "+${country.dialCode} $phoneNumber";
  }
}