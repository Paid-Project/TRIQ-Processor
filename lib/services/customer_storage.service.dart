import 'package:hive_flutter/hive_flutter.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/customer.service.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

class CustomerStorageService {
  static final CustomerStorageService _instance =
      CustomerStorageService._internal();
  factory CustomerStorageService() => _instance;
  CustomerStorageService._internal();

  final _customerService = locator<CustomerService>();
  static const String _customerBoxKey = 'customer_data';
  static const String _customerIdKey = 'customer_id';

  /// Get stored customer data
  Customer? getStoredCustomer() {
    try {
      final box = Hive.box(AppStrings.triqBox);
      final customerData = box.get(_customerBoxKey);
      if (customerData != null) {
        return Customer.fromJson(Map<String, dynamic>.from(customerData));
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting stored customer: $e');
      return null;
    }
  }

  /// Store customer data locally
  Future<void> storeCustomer(Customer customer) async {
    try {
      final box = Hive.box(AppStrings.triqBox);
      await box.put(_customerBoxKey, customer.toJson());
      await box.put(_customerIdKey, customer.id);
      AppLogger.info('Customer data stored successfully: ${customer.id}');
    } catch (e) {
      AppLogger.error('Error storing customer data: $e');
    }
  }

  /// Get stored customer ID
  String? getStoredCustomerId() {
    try {
      final box = Hive.box(AppStrings.triqBox);
      return box.get(_customerIdKey);
    } catch (e) {
      AppLogger.error('Error getting stored customer ID: $e');
      return null;
    }
  }

  /// Clear stored customer data
  Future<void> clearCustomerData() async {
    try {
      final box = Hive.box(AppStrings.triqBox);
      await box.delete(_customerBoxKey);
      await box.delete(_customerIdKey);
      AppLogger.info('Customer data cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing customer data: $e');
    }
  }

  /// Fetch and store customer data by ID
  Future<Customer?> fetchAndStoreCustomer(String customerId) async {
    try {
      AppLogger.info('Fetching customer data for ID: $customerId');

      final result = await _customerService.getCustomerById(customerId);

      return result.fold(
        (failure) {
          AppLogger.error('Failed to fetch customer: ${failure.message}');
          return null;
        },
        (customer) async {
          await storeCustomer(customer);
          AppLogger.info(
            'Customer data fetched and stored successfully: ${customer.id}',
          );
          return customer;
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching and storing customer: $e');
      return null;
    }
  }

  /// Check if customer data is available locally
  bool hasStoredCustomer() {
    return getStoredCustomer() != null;
  }

  /// Get customer QR code if available
  String? getCustomerQRCode() {
    final customer = getStoredCustomer();
    return customer?.qrCode;
  }

  /// Get customer user image if available
  String? getCustomerUserImage() {
    final customer = getStoredCustomer();
    return customer?.userImage;
  }

  /// Get customer machines if available
  List<MachineElement>? getCustomerMachines() {
    final customer = getStoredCustomer();
    return customer?.machines;
  }
}
