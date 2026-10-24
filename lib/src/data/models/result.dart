abstract class Result<T> {
  T? call();
}

class Success<T> extends Result<T> {
  final T? data;

  Success(this.data);

  @override
  T? call() => data;
}

class Fail<T> extends Result<T> {
  final String message;
  final Exception? e;
  final int? code;

  Fail(this.message, {this.e, this.code});

  @override
  T? call() => null;
}

class Loading<T> extends Result<T> {
  @override
  T? call() => null;
}
