import 'package:flutter/cupertino.dart';

class HomeCardModel {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String route;
  final int colorCode;
  final IconData iconData;
  final String iconUrl;

  HomeCardModel({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.route,
    required this.colorCode,
    required this.iconData,
    required this.id,
    required this.iconUrl,
  });
}
