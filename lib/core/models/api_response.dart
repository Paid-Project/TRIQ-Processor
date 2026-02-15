/// API Response model for handling standardized API responses
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data:
          json['data'] != null && fromJsonT != null
              ? fromJsonT(json['data'])
              : json['data'],
      message: json['message'],
      statusCode: json['statusCode'] ?? 200,
      errors: json['errors'],
    );
  }

  /// Create ApiResponse from raw response data (for non-JSON responses)
  factory ApiResponse.fromRawData(
    dynamic rawData,
    int statusCode,
    T Function(dynamic)? fromJsonT,
  ) {
    bool success = statusCode >= 200 && statusCode < 300;

    return ApiResponse<T>(
      success: success,
      data: fromJsonT != null ? fromJsonT(rawData) : rawData,
      message: success ? 'Success' : 'Error occurred',
      statusCode: statusCode,
    );
  }

  /// Check if the response is successful (2xx status codes)
  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;

  /// Check if the response indicates a client error (4xx status codes)
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Check if the response indicates a server error (5xx status codes)
  bool get isServerError => statusCode >= 500;

  /// Get error message with fallback
  String get errorMessage {
    if (message != null && message!.isNotEmpty) {
      return message!;
    }

    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.first.toString();
    }

    return _getDefaultErrorMessage();
  }

  String _getDefaultErrorMessage() {
    switch (statusCode) {
      case 400:
        return 'Bad Request - Invalid data provided';
      case 401:
        return 'Unauthorized - Please login again';
      case 403:
        return 'Forbidden - You do not have permission';
      case 404:
        return 'Not Found - Resource not available';
      case 422:
        return 'Validation Error - Please check your input';
      case 429:
        return 'Too Many Requests - Please try again later';
      case 500:
        return 'Internal Server Error - Please try again later';
      case 502:
        return 'Bad Gateway - Service temporarily unavailable';
      case 503:
        return 'Service Unavailable - Please try again later';
      case 504:
        return 'Gateway Timeout - Request timed out';
      default:
        return 'An unexpected error occurred';
    }
  }
}
