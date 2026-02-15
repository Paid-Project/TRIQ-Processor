import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/machine_supplier_model.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';

import '../core/utils/failures.dart';

class MachineSupplierService {
  final apiService = locator<ApiService>();

  ResultFuture<MachineSupplierModel> getMachineSupplier() async {
    try {
      final response = await apiService.get(
        url: ApiEndpoints.getMachineSupplier,
      );

      // Based on the curl response, the data is directly under 'data' key
      if (response.data['data'] != null) {
        return Right(MachineSupplierModel.fromJson(response.data));
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Invalid response format'),
        );
      }
    } catch (e) {
      AppLogger.error("Error getting machine supplier data: $e");
      if (e is DioException) {
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      return Left(
        Failure('Failed to get machine supplier data: ${e.toString()}'),
      );
    }
  }
}
