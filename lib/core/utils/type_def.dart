import 'package:dartz/dartz.dart';

import 'failures.dart';

/// **EitherResult<T>**
///
/// A shorthand alias for the `Either` type from the `dartz` package
/// that represents a result which may be either:
/// - a **success** of type `T` (`Right<T>`)
/// - or a **failure** of type `Exception` (`Left<Exception>`)
///
/// This is commonly used to model operations that can fail.
///
/// **Type Parameters:**
/// - `T`: The expected success type.
///
/// **Usage Example:**
/// ```dart
/// EitherResult<int> divide(int a, int b) {
///   if (b == 0) return Left(Exception('Division by zero'));
///   return Right(a ~/ b);
/// }
/// ```
typedef EitherResult<T> = Either<Failure, T>;

/// **ResultFuture&lt;T&gt;**
///
/// A type alias for handling asynchronous results using the `Either` type
/// from the `dartz` package.
///
/// **Type Parameters:**
/// - `T`: The expected success type of the result.
///
/// This alias represents a future that either returns:
/// - **`Right<T>`** (successful result)
/// - **`Left<Exception>`** (error/exception)
///
/// **Usage Example:**
/// ```dart
/// ResultFuture<User> getUserData() async {
///   try {
///     final user = await userRepository.fetchUser();
///     return Right(user);
///   } catch (e) {
///     return Left(Exception('Failed to fetch user'));
///   }
/// }
/// ```
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// **ResultVoid**
///
/// A shorthand alias for a `ResultFuture<void>`, representing operations
/// that do not return a value but can succeed or fail.
///
/// **Usage Example:**
/// ```dart
/// ResultVoid logoutUser() async {
///   try {
///     await authRepository.logout();
///     return Right(null);
///   } catch (e) {
///     return Left(Exception('Logout failed'));
///   }
/// }
/// ```
typedef ResultVoid = ResultFuture<void>;

/// **DataMap**
///
/// A shorthand alias for `Map<String, dynamic>`, commonly used for API
/// responses, JSON structures, or passing generic key-value data.
///
/// **Usage Example:**
/// ```dart
/// DataMap userData = {
///   "id": 123,
///   "name": "John Doe",
///   "email": "john@example.com"
/// };
/// ```
typedef DataMap = Map<String, dynamic>;
