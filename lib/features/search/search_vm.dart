import 'package:flutter/material.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/search/search_view.dart';
import 'package:manager/core/models/organization.dart';
import 'package:manager/services/api.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../core/locator.dart';

class SearchViewModel extends ReactiveViewModel {
  final navigationService = locator<NavigationService>();
  final _apiService = locator<ApiService>();

  final TextEditingController searchController = TextEditingController();

  bool _searching = false;
  bool get searching => _searching;

  List<Organization> _searchResults = [];
  List<Organization> get searchResults => _searchResults;

  late String apiEndpoint;
  late Function(Organization) onSelectCallback;

  void init(SearchViewAttributes attributes) {
    apiEndpoint = attributes.apiEndPoint;
    onSelectCallback = attributes.onSelect;
  }

  void onSearchChanged(String value) async {
    if (value.isEmpty) {
      _searching = false;
      _searchResults = [];
    } else {
      _searching = true;
      notifyListeners();

      try {
        final response = await _apiService.get(
          url: '$apiEndpoint?search=$value',
        );

        if (response.data['success'] == true) {
          _searchResults = (response.data['data'] as List)
              .map((json) => Organization.fromJson(json))
              .toList();
        } else {
          _searchResults = [];
        }
      } catch (e) {
        _searchResults = [];
        AppLogger.error('Search error: $e');
      } finally {
        _searching = false;
        notifyListeners();
      }
    }
    notifyListeners();
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [];
}

class Organization {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String organizationType;
  final String industry;

  Organization({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.organizationType,
    required this.industry,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] ?? json['_id']??'',
      name: json['name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      organizationType: json['organizationType'] ?? '',
      industry: json['industry'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullName': name,
      'email': email,
      'phone': phone,
      'organizationType': organizationType,
      'industry': industry,
    };
  }
}