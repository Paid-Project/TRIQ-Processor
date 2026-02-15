import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/failures.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';

class CustomerService {
  final _apiService = locator<ApiService>();

  /// Respond to machine assignment request (accept or reject)
  ResultFuture<bool> respondToMachineAssignment({

    required String customerId,
    required String action, // 'accept' or 'reject'
    String? notificationId,
  }) async {
    try {

      final Map<String, dynamic> requestData = {

        'customerId': customerId,
        'action': action,
        if (notificationId != null && notificationId.isNotEmpty) 'notificationId': notificationId,
      };

      AppLogger.info("Request data: $requestData");

      final response = await _apiService.post(
        url: ApiEndpoints.respondMachineAssignment,
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        if (data != null && (data['success'] == true || data['status'] == 1)) {
          AppLogger.info("Machine assignment response successful: $action");
          return Right(true);
        } else {
          final errorMessage = data?['message'] ?? 'Failed to respond to machine assignment';
          AppLogger.error("Machine assignment response failed: $errorMessage");
          return Left(Failure(errorMessage));
        }
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to respond to machine assignment';
        AppLogger.error("Machine assignment API error: ${response.statusCode} - $errorMessage");
        return Left(Failure(errorMessage));
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Network error';
      AppLogger.error("DioException in respondToMachineAssignment: $errorMessage");
      return Left(Failure(errorMessage));
    } catch (e) {
      AppLogger.error("Exception in respondToMachineAssignment: $e");
      return Left(Failure('Something went wrong: ${e.toString()}'));
    }
  }

  /// Create a new customer
  ResultFuture<Customer> createCustomer({
    required String phoneNumber,
    required String email,
    required String customerName,
    required String contactPerson,
    required String designation,
    required List<Map<String, dynamic>> machines,
  }) async {
    try {
      AppLogger.info("Creating customer: $customerName");

      final Map<String, dynamic> requestData = {
        'phoneNumber': phoneNumber,
        'email': email,
        'customerName': customerName,
        'contactPerson': contactPerson,
        'designation': designation,
        'machines': machines,
      };

      AppLogger.info("Request data: $requestData");

      final response = await _apiService.post(url: ApiEndpoints.createCustomer, data: requestData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data != null && data['data'] != null) {
          final customer = Customer.fromJson(data['data']);
          AppLogger.info("Customer created successfully: ${customer.id}");
          return Right(customer);
        } else {
          AppLogger.error("Invalid response format: $data");
          return Left(Failure('Invalid response format'));
        }
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to create customer';
        AppLogger.error("API error: $errorMessage (Status: ${response.statusCode})");
        return Left(Failure(errorMessage));
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Network error occurred';
      AppLogger.error("DioException while creating customer: $errorMessage");
      return Left(Failure(errorMessage));
    } catch (e) {
      AppLogger.error("Exception while creating customer: $e");
      return Left(Failure('Unexpected error occurred: $e'));
    }
  }

  /// Get a customer by ID
  ResultFuture<Customer> getCustomerById(String customerId) async {
    try {
      AppLogger.info("Fetching customer by ID: $customerId");

      final response = await _apiService.get(url: '${ApiEndpoints.getCustomerById}/$customerId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          // The API returns customer data directly, not wrapped in 'data' field
          final customer = Customer.fromJson(data);
          AppLogger.info("Customer fetched successfully: ${customer.id}");
          return Right(customer);
        } else {
          AppLogger.error("Invalid response format: $data");
          return Left(Failure('Invalid response format'));
        }
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to fetch customer';
        AppLogger.error("API error: $errorMessage (Status: ${response.statusCode})");
        return Left(Failure(errorMessage));
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Network error occurred';
      AppLogger.error("DioException while fetching customer: $errorMessage");
      return Left(Failure(errorMessage));
    } catch (e) {
      AppLogger.error("Exception while fetching customer: $e");
      return Left(Failure('Unexpected error occurred: $e'));
    }
  }

  /// Get all customers
  ResultFuture<List<Customer>> getCustomers() async {
    try {
      AppLogger.info("Fetching customers");

      final response = await _apiService.get(url: ApiEndpoints.getCustomers);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          final List<dynamic> customersData = data['data'];
          final customers = customersData.map((json) => Customer.fromJson(json)).toList();
          AppLogger.info("Fetched ${customers.length} customers");
          return Right(customers);
        } else {
          AppLogger.warning("No customers found");
          return Right([]);
        }
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to fetch customers';
        AppLogger.error("API error: $errorMessage (Status: ${response.statusCode})");
        return Left(Failure(errorMessage));
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Network error occurred';
      AppLogger.error("DioException while fetching customers: $errorMessage");
      return Left(Failure(errorMessage));
    } catch (e) {
      AppLogger.error("Exception while fetching customers: $e");
      return Left(Failure('Unexpected error occurred: $e'));
    }
  }

  /// Search customers by query
  ResultFuture<List<Customer>> searchCustomers(String query) async {
    try {
      AppLogger.info("Searching customers with query: $query");

      final response = await _apiService.get(url: ApiEndpoints.searchCustomers, queryParameters: {'search': query});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          final List<dynamic> customersData = data['data'];
          final customers = customersData.map((json) => Customer.fromJson(json)).toList();
          AppLogger.info("Found ${customers.length} customers for query: $query");
          return Right(customers);
        } else {
          AppLogger.warning("No customers found for query: $query");
          return Right([]);
        }
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to search customers';
        AppLogger.error("API error: $errorMessage (Status: ${response.statusCode})");
        return Left(Failure(errorMessage));
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Network error occurred';
      AppLogger.error("DioException while searching customers: $errorMessage");
      return Left(Failure(errorMessage));
    } catch (e) {
      AppLogger.error("Exception while searching customers: $e");
      return Left(Failure('Unexpected error occurred: $e'));
    }
  }

  /// Delete a customer
  ResultFuture<bool> deleteCustomer(String customerId) async {
    try {
      AppLogger.info("Deleting customer: $customerId");

      final response = await _apiService.delete(url: '${ApiEndpoints.deleteCustomer}/$customerId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['message'] != null) {
          AppLogger.info("Customer deleted successfully: $customerId");
          return const Right(true);
        } else {
          AppLogger.error("Invalid response format: $data");
          return Left(Failure('Invalid response format'));
        }
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to delete customer';
        AppLogger.error("API error: $errorMessage (Status: ${response.statusCode})");
        return Left(Failure(errorMessage));
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Network error occurred';
      AppLogger.error("DioException while deleting customer: $errorMessage");
      return Left(Failure(errorMessage));
    } catch (e) {
      AppLogger.error("Exception while deleting customer: $e");
      return Left(Failure('Unexpected error occurred: $e'));
    }
  }

  /// Update an existing customer
  ResultFuture<Customer> updateCustomer({
    required String customerId,
    required String phoneNumber,
    required String email,
    required String customerName,
    required String contactPerson,
    required String designation,
    required List<Map<String, dynamic>> machines,
  }) async {
    AppLogger.info("Updating customer: $customerName (ID: $customerId)");

    final Map<String, dynamic> requestData = {
      'phoneNumber': phoneNumber,
      'email': email,
      'customerName': customerName,
      'contactPerson': contactPerson,
      'designation': designation,
      'machines': machines,
    };

    AppLogger.info("Request data: $requestData");

    final response = await _apiService.put(url: '${ApiEndpoints.updateCustomer}/$customerId', data: requestData);

    if (response.statusCode == 200) {
      final data = response.data;

      if (data != null && data['data'] != null) {
        final customer = Customer.fromJson(data['data']);
        AppLogger.info("Customer updated successfully: ${customer.id}");
        return Right(customer);
      } else {
        AppLogger.error("Invalid response format: $data");
        return Left(Failure('Invalid response format'));
      }
    } else {
      final errorMessage = response.data?['message'] ?? 'Failed to update customer';
      AppLogger.error("API error: $errorMessage (Status: ${response.statusCode})");
      return Left(Failure(errorMessage));
    }
  }

  /// Remove a machine from a customer
  ResultFuture<Customer> removeMachine({required String customerId, required String machineId}) async {
    try {
      AppLogger.info("Removing machine $machineId from customer: $customerId");

      final response = await _apiService.post(url: '${ApiEndpoints.removeMachine}/$customerId/$machineId', data: {});

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['data'] != null) {
          final customer = Customer.fromJson(data['data']);
          AppLogger.info("Machine removed successfully from customer: ${customer.id}");
          return Right(customer);
        } else {
          AppLogger.error("Invalid response format: $data");
          return Left(Failure('Invalid response format'));
        }
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to remove machine from customer';
        AppLogger.error("API error: $errorMessage (Status: ${response.statusCode})");
        return Left(Failure(errorMessage));
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Network error occurred';
      AppLogger.error("DioException while removing machine: $errorMessage");
      return Left(Failure(errorMessage));
    } catch (e) {
      AppLogger.error("Exception while removing machine: $e");
      return Left(Failure('Unexpected error occurred: $e'));
    }
  }
}
