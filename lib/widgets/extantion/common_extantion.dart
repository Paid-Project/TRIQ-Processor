import 'package:intl/intl.dart';
import 'package:manager/api_endpoints.dart';

extension UrlPrefixExtension on String {

  // 1. Remove '=> ()' from here
  String get prefixWithBaseUrl {

    final cleanBase =ApiEndpoints.image_base ;

    final cleanPath = this.startsWith('/')
        ? this.substring(1)
        : this;

    return this.contains(cleanBase)?this:'$cleanBase$cleanPath';
  }

  String get capitalizeWords {
    String text=this;
    if (text.isEmpty) return text;

    return text
        .split(' ')                         // words me split
        .map((word) =>
    word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}

extension DateTimeFormating on DateTime {
  String formatReadableDate() {
    try {
      final dateTime = DateTime.parse(this.toIso8601String());
      final formatter = DateFormat('MMM dd,yyyy HH:mm');
      return formatter.format(dateTime);
    } catch (e) {
      return this.toIso8601String();
    }
  }

}
