import 'package:manager/core/locator.dart';
import 'package:manager/services/customer_storage.service.dart';

/// Example usage of CustomerStorageService
/// This file demonstrates how to use the customer storage service
/// to fetch, store, and retrieve customer data locally.

class CustomerDataUsageExample {
  final _customerStorageService = locator<CustomerStorageService>();

  /// Example: Fetch and store customer data after login
  Future<void> fetchCustomerDataAfterLogin(String userId) async {
    try {
      // Fetch customer data from API and store locally
      final customer = await _customerStorageService.fetchAndStoreCustomer(
        userId,
      );

      if (customer != null) {
        print('Customer data fetched and stored successfully:');
        print('Customer Name: ${customer.customerName}');
        print('Email: ${customer.email}');
        print('Phone: ${customer.phoneNumber}');
        print('QR Code available: ${customer.qrCode != null}');
        print('User Image available: ${customer.userImage != null}');
        print('Machines count: ${customer.machines?.length ?? 0}');
      } else {
        print('Failed to fetch customer data');
      }
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  /// Example: Get stored customer data
  void getStoredCustomerData() {
    final customer = _customerStorageService.getStoredCustomer();

    if (customer != null) {
      print('Stored Customer Data:');
      print('ID: ${customer.id}');
      print('Name: ${customer.customerName}');
      print('Email: ${customer.email}');
      print('Phone: ${customer.phoneNumber}');
      print('Contact Person: ${customer.contactPerson}');
      print('Designation: ${customer.designation}');
      print('Country: ${customer.countryOrigin}');
      print('Flag: ${customer.flag}');
      print(
        'QR Code: ${customer.qrCode != null ? 'Available' : 'Not available'}',
      );
      print(
        'User Image: ${customer.userImage != null ? 'Available' : 'Not available'}',
      );

      // Print machine details
      if (customer.machines != null && customer.machines!.isNotEmpty) {
        print('Machines:');
        for (int i = 0; i < customer.machines!.length; i++) {
          final machine = customer.machines![i];
          print('  Machine ${i + 1}:');
          print('    Name: ${machine.machine?.machineName}');
          print('    Model: ${machine.machine?.modelNumber}');
          print('    Type: ${machine.machine?.machineType}');
          print('    Status: ${machine.machine?.status}');
          print('    Purchase Date: ${machine.purchaseDate}');
          print('    Installation Date: ${machine.installationDate}');
          print('    Warranty Status: ${machine.warrantyStatus}');
        }
      }
    } else {
      print('No customer data stored locally');
    }
  }

  /// Example: Get specific customer data
  void getSpecificCustomerData() {
    // Get QR code
    final qrCode = _customerStorageService.getCustomerQRCode();
    if (qrCode != null) {
      print('Customer QR Code: $qrCode');
    } else {
      print('No QR code available');
    }

    // Get user image
    final userImage = _customerStorageService.getCustomerUserImage();
    if (userImage != null) {
      print('Customer User Image: $userImage');
    } else {
      print('No user image available');
    }

    // Get machines
    final machines = _customerStorageService.getCustomerMachines();
    if (machines != null && machines.isNotEmpty) {
      print('Customer has ${machines.length} machines');
    } else {
      print('No machines available');
    }
  }

  /// Example: Check if customer data is available
  void checkCustomerDataAvailability() {
    final hasData = _customerStorageService.hasStoredCustomer();
    print('Customer data available locally: $hasData');

    if (hasData) {
      final customerId = _customerStorageService.getStoredCustomerId();
      print('Stored customer ID: $customerId');
    }
  }

  /// Example: Clear customer data (useful for logout)
  Future<void> clearCustomerData() async {
    await _customerStorageService.clearCustomerData();
    print('Customer data cleared successfully');
  }
}

/// Usage in your manager:
/// 
/// 1. Customer data is automatically fetched in the profile screen for processor role users:
///    - The ProfileViewModel automatically calls the API when the profile loads
///    - Only users with processor role will trigger the API call
///    - Data is stored locally and displayed in the profile
/// 
/// 2. To get stored customer data:
///    ```dart
///    final example = CustomerDataUsageExample();
///    example.getStoredCustomerData();
///    ```
/// 
/// 3. To check if data is available:
///    ```dart
///    final example = CustomerDataUsageExample();
///    example.checkCustomerDataAvailability();
///    ```
/// 
/// 4. To clear data on logout:
///    ```dart
///    final example = CustomerDataUsageExample();
///    await example.clearCustomerData();
///    ```
