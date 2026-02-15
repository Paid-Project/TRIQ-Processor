import 'package:manager/core/utils/type_def.dart';

/// **UseCaseWithParams**
///
/// A base class for use cases that require parameters.
///
/// This abstract class follows the **clean architecture** principle,
/// enforcing a contract for executing a use case with input parameters.
///
/// **Type Parameters:**
/// - `Type`: The type of data the use case returns.
/// - `Params`: The type of parameters required by the use case.
///
/// **Usage Example:**
/// ```dart
/// class GetUserProfile extends UseCaseWithParams<User, UserParams> {
///   @override
///   ResultFuture<User> call(UserParams params) {
///     // Implementation here
///   }
/// }
/// ```
///
/// **Method:**
/// - `call(Params params) → ResultFuture<Type>`:
///   - Executes the use case with the given parameters.
abstract class UseCaseWithParams<Type, Params> {
  /// Creates an instance of `UseCaseWithParams`.
  const UseCaseWithParams();

  /// Executes the use case with the given parameters.
  ResultFuture<Type> call(Params params);
}

/// **UseCaseWithoutParams**
///
/// A base class for use cases that do not require parameters.
///
/// This abstract class ensures a consistent structure for executing a use case
/// without input parameters, adhering to the **clean architecture** approach.
///
/// **Type Parameters:**
/// - `Type`: The type of data the use case returns.
///
/// **Usage Example:**
/// ```dart
/// class GetAppSettings extends UseCaseWithoutParams<Settings> {
///   @override
///   ResultFuture<Settings> call() {
///     // Implementation here
///   }
/// }
/// ```
///
/// **Method:**
/// - `call() → ResultFuture<Type>`:
///   - Executes the use case without requiring any parameters.
abstract class UseCaseWithoutParams<Type> {
  /// Creates an instance of `UseCaseWithoutParams`.
  const UseCaseWithoutParams();

  /// Executes the use case without any parameters.
  ResultFuture<Type> call();
}
