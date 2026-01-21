import 'package:flutter/widgets.dart';
import 'multi_form_fields_mixin.dart';

/// A generic `InheritedWidget` that provides access to a `MultiFormFieldsMixin`
/// instance within the widget tree. This is useful for managing and sharing
/// state across multiple form fields.
///
/// The `MultiFormScope` class is parameterized with:
/// - `K`: The type of the key used in the form fields.
/// - `T`: A type that extends `StatefulWidget`, representing the widget type
///   associated with the form fields.
class MultiFormScope<K, T extends StatefulWidget> extends InheritedWidget {
  /// The mixin instance that holds the state and logic for the form fields.
  final MultiFormFieldsMixin<K, T> mixin;

  /// Creates a `MultiFormScope` widget.
  ///
  /// - `key`: An optional key for the widget.
  /// - `mixin`: The `MultiFormFieldsMixin` instance to be provided to the widget tree.
  /// - `child`: The child widget that will have access to the `mixin`.
  const MultiFormScope({super.key, required this.mixin, required super.child});

  /// Retrieves the `MultiFormFieldsMixin` instance from the nearest ancestor
  /// `MultiFormScope` widget in the widget tree.
  ///
  /// - `context`: The `BuildContext` used to locate the `MultiFormScope`.
  ///
  /// Throws an assertion error if no `MultiFormScope` is found in the widget tree.
  static MultiFormFieldsMixin<K, T> of<K, T extends StatefulWidget>(
      BuildContext context,
      ) {
    final MultiFormScope<K, T>? result =
    context
        .getElementForInheritedWidgetOfExactType<MultiFormScope<K, T>>()
        ?.widget
    as MultiFormScope<K, T>?;
    assert(result != null, 'No MultiFormScope found in context');
    return result!.mixin;
  }

  /// Determines whether the widget should notify its dependents when it is updated.
  ///
  /// Always returns `false` as this widget does not depend on updates to notify
  /// its dependents.
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

/// An extension on `BuildContext` to simplify access to the `MultiFormFieldsMixin`
/// instance provided by the nearest `MultiFormScope` widget.
///
/// This extension adds a `multipleForm` method to `BuildContext` that retrieves
/// the `MultiFormFieldsMixin` instance.
extension MultipleFormFieldExtension on BuildContext {
  /// Retrieves the `MultiFormFieldsMixin` instance from the nearest ancestor
  /// `MultiFormScope` widget in the widget tree.
  ///
  /// - `K`: The type of the key used in the form fields.
  /// - `T`: A type that extends `StatefulWidget`, representing the widget type
  ///   associated with the form fields.
  MultiFormFieldsMixin<K, T> multipleForm<K, T extends StatefulWidget>() =>
      MultiFormScope.of<K, T>(this);
}
