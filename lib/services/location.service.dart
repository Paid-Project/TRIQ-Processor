import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';

import '../core/utils/failures.dart';

/// Location Service
/// Handles location-related API calls (countries, states, cities)
class LocationService {
  final apiService = locator<ApiService>();

  /// Get states/provinces by country
  /// Returns list of states for the selected country
  ResultFuture<List<StateModel>> getStatesByCountry(String country) async {
    try {
      final response = await apiService.get(
        url: '${ApiEndpoints.getStatesByCountry}?country=$country',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> statesData = response.data['data'] ?? [];
        final states = statesData
            .map((json) => StateModel.fromJson(json))
            .toList();
        return Right(states);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to get states'),
        );
      }
    } catch (e) {
      AppLogger.error("Error getting states by country: $e");
      if (e is DioException) {
        return Left(
          Failure(e.response?.data?['message'] ?? 'Network error'),
        );
      }
      return Left(
        Failure('Failed to get states: ${e.toString()}'),
      );
    }
  }

  /// Get cities by state
  /// Returns list of cities for the selected state
  ResultFuture<List<CityModel>> getCitiesByState(String state) async {
    try {
      final response = await apiService.get(
        url: '${ApiEndpoints.getCitiesByState}?state=$state',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> citiesData = response.data['data'] ?? [];
        final cities = citiesData
            .map((json) => CityModel.fromJson(json))
            .toList();
        return Right(cities);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to get cities'),
        );
      }
    } catch (e) {
      AppLogger.error("Error getting cities by state: $e");
      if (e is DioException) {
        return Left(
          Failure(e.response?.data?['message'] ?? 'Network error'),
        );
      }
      return Left(
        Failure('Failed to get cities: ${e.toString()}'),
      );
    }
  }

  /// DUMMY DATA - Remove when backend is ready
  /// Returns dummy states for testing
  Future<List<StateModel>> getDummyStatesByCountry(String country) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    if (country.toLowerCase() == 'india') {
      return [
        StateModel(id: '1', name: 'Maharashtra', code: 'MH'),
        StateModel(id: '2', name: 'Karnataka', code: 'KA'),
        StateModel(id: '3', name: 'Tamil Nadu', code: 'TN'),
        StateModel(id: '4', name: 'Gujarat', code: 'GJ'),
        StateModel(id: '5', name: 'Rajasthan', code: 'RJ'),
        StateModel(id: '6', name: 'Uttar Pradesh', code: 'UP'),
        StateModel(id: '7', name: 'Delhi', code: 'DL'),
        StateModel(id: '8', name: 'Punjab', code: 'PB'),
      ];
    } else if (country.toLowerCase() == 'usa' || country.toLowerCase() == 'united states') {
      return [
        StateModel(id: '1', name: 'California', code: 'CA'),
        StateModel(id: '2', name: 'Texas', code: 'TX'),
        StateModel(id: '3', name: 'New York', code: 'NY'),
        StateModel(id: '4', name: 'Florida', code: 'FL'),
        StateModel(id: '5', name: 'Illinois', code: 'IL'),
      ];
    }
    
    return [];
  }
}

/// State/Province Model
class StateModel {
  final String id;
  final String name;
  final String code;

  StateModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}

/// City Model
class CityModel {
  final String id;
  final String name;

  CityModel({
    required this.id,
    required this.name,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
