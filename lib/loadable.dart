import 'package:treeed/treeed.dart';

abstract class LoadableValue<T, E> {
  const LoadableValue();

  U bind<U>({
    required U Function() loading,
    required U Function(T) got,
    U Function(E)? failure,
  });
  T valueOr(T placeholder);
  bool get isLoading;
  bool get isFailure;
}

class Loading<T, E> extends LoadableValue<T, E> {
  @override
  U bind<U>({
    required U Function() loading,
    required U Function(T) got,
    U Function(E)? failure,
  }) => loading();

  @override
  T valueOr(T placeholder, {T? ifError}) => placeholder;

  @override
  bool get isLoading => true;

  @override
  bool get isFailure => false;
}

class Got<T, E> extends LoadableValue<T, E> {
  const Got(this.value);
  final T value;

  @override
  U bind<U>({
    required U Function() loading,
    required U Function(T) got,
    U Function(E)? failure,
  }) => got(value);

  @override
  T valueOr(T placeholder) => value;

  @override
  bool get isLoading => false;

  @override
  bool get isFailure => false;
}

class Failure<T, E> extends LoadableValue<T, E> {
  const Failure(this.error);

  final E error;

  @override
  U bind<U>({
    required U Function() loading,
    required U Function(T) got,
    U Function(E)? failure,
  }) => failure != null ? failure(error) : loading();

  @override
  T valueOr(T placeholder) => placeholder;

  @override
  bool get isLoading => false;

  @override
  bool get isFailure => true;
}

extension LoadableStateGroupExt on TreeedGroup {
  TreeedState<LoadableValue<T, E>> tsLoadableFailable<T, E>() =>
      ts<LoadableValue<T, E>>(Loading());
  TreeedState<LoadableValue<T, dynamic>> tsLoadable<T>() =>
      ts<LoadableValue<T, dynamic>>(Loading());
}
