import 'package:flutter/foundation.dart';

@immutable
class FormKey<T> {
  final T key;

  const FormKey(this.key);

  @override
  bool operator ==(Object other) => other is FormKey<T> && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'FormKey<$T>($key)';
}
