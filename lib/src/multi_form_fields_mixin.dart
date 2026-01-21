import 'dart:async';
import 'package:flutter/material.dart';

/// A mixin that provides advanced form field management with debouncing and focus control.
///
/// This mixin helps manage multiple [TextEditingController]s and [FocusNode]s
/// efficiently, with built-in debouncing support for text input changes.
///
/// Type Parameters:
/// * [K] - The key type used to identify form fields (e.g., enum, String, int)
/// * [T] - The [StatefulWidget] type this mixin is applied to
///
/// Example:
/// ```dart
/// enum FormField { email, password, username }
///
/// class MyFormState extends State<MyForm> with MultiFormFieldsMixin<FormField, MyForm> {
///   @override
///   void initState() {
///     super.initState();
///     initControllers(
///       FormField.values,
///       withFocusNode: true,
///       initialValues: {
///         FormField.email: 'user@example.com',
///       },
///     );
///   }
///
///   @override
///   void onFieldChanged(FormField key, String value) {
///     print('Field $key changed to: $value');
///   }
///
///   @override
///   void onFieldDebounced(FormField key, String value) {
///     // Perform expensive operations like API calls here
///     print('Field $key debounced with: $value');
///   }
/// }
/// ```
mixin MultiFormFieldsMixin<K, T extends StatefulWidget> on State<T> {
  final Map<K, TextEditingController> _controllers = {};
  final Map<K, FocusNode> _focusNodes = {};
  final Map<K, VoidCallback> _listeners = {};
  final Map<K, Timer?> _debounceTimers = {};
  final Map<K, Duration> _debounceDurations = {};
  final Map<K, String> _lastTexts = {};

  /// The default debounce duration applied to all fields unless overridden.
  ///
  /// This duration is used to delay the [onFieldDebounced] callback after
  /// the user stops typing. Default is 600 milliseconds.
  /// The default debounce duration applied to all fields unless overridden.
  ///
  /// This duration is used to delay the [onFieldDebounced] callback after
  /// the user stops typing. Default is 600 milliseconds.
  Duration defaultDebounce = const Duration(milliseconds: 600);

  /// Returns the [TextEditingController] associated with the given [key].
  ///
  /// Returns `null` if no controller exists for the given key.
  TextEditingController? getController(K key) => _controllers[key];

  /// Returns the [FocusNode] associated with the given [key].
  ///
  /// Returns `null` if no focus node exists for the given key.
  FocusNode? getFocusNode(K key) => _focusNodes[key];

  /// Checks whether a [FocusNode] exists for the given [key].
  ///
  /// Returns `true` if a focus node has been created for this key.
  bool hasFocusNode(K key) => _focusNodes.containsKey(key);

  /// Checks whether the field with the given [key] currently has focus.
  ///
  /// Returns `false` if no focus node exists for the key or if the field
  /// doesn't have focus.
  bool hasFocus(K key) => _focusNodes[key]?.hasFocus ?? false;

  /// Returns the current text value of the field with the given [key].
  ///
  /// Returns `null` if:
  /// * No controller exists for the key
  /// * The text is empty or contains only whitespace
  ///
  /// Otherwise returns the trimmed text value.
  /// Returns the current text value of the field with the given [key].
  ///
  /// Returns `null` if:
  /// * No controller exists for the key
  /// * The text is empty or contains only whitespace
  ///
  /// Otherwise returns the trimmed text value.
  String? getText(K key) => (_controllers[key]?.text).isNullOrBlank()
      ? null
      : _controllers[key]?.text;

  /// Sets the text value of the field with the given [key].
  ///
  /// Parameters:
  /// * [key] - The key identifying the field
  /// * [text] - The new text value to set
  /// * [notify] - If `true`, triggers the change listener and debounce timer.
  ///   If `false` (default), updates the text without triggering callbacks.
  ///
  /// This method will:
  /// * Do nothing if no controller exists for the key
  /// * Do nothing if the current text equals the new text
  /// * Move the cursor to the end of the text
  /// * Update the internal last text cache
  void setText(K key, String text, {bool notify = false}) {
    final c = _controllers[key];
    final l = _listeners[key];
    if (c == null) return;

    if (c.text == text) return;

    if (!notify && l != null) c.removeListener(l);
    c.text = text;
    c.selection = TextSelection.fromPosition(
      TextPosition(offset: c.text.length),
    );
    _lastTexts[key] = text;
    if (!notify && l != null) c.addListener(l);
  }

  /// Checks whether a [TextEditingController] exists for the given [key].
  ///
  /// Returns `true` if a controller has been initialized for this key.
  bool hasController(K key) => _controllers.containsKey(key);

  /// Internal method that handles text changes for a field.
  ///
  /// This method is called whenever the text in a controller changes.
  /// It triggers [onFieldChanged] immediately and schedules [onFieldDebounced]
  /// to be called after the debounce duration.
  void _onChanged(K key) {
    final c = _controllers[key];
    if (c == null) return;

    final currentText = c.text;
    final lastText = _lastTexts[key];

    if (currentText == lastText) return;
    _lastTexts[key] = currentText;

    onFieldChanged(key, currentText);

    final dur = _debounceDurations[key] ?? defaultDebounce;
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(dur, () {
      final current = _controllers[key];
      if (current != null && _lastTexts[key] == current.text) {
        onFieldDebounced.call(key, current.text);
      }
    });
  }

  /// Internal method that initializes a controller for the given [key].
  ///
  /// Parameters:
  /// * [key] - The key identifying the field
  /// * [initialValue] - Optional initial text value
  /// * [debounceDuration] - Optional custom debounce duration for this field
  /// * [withFocusNodes] - If `true`, creates a [FocusNode] for this field
  ///
  /// If a controller already exists for the key, this method will only update
  /// the text value if [initialValue] is provided.
  void _initController(
    K key, {
    String? initialValue,
    Duration? debounceDuration,
    bool withFocusNodes = false,
  }) {
    if (hasController(key)) {
      if (initialValue != null) {
        setText(key, initialValue);
      }
      return;
    }

    final controller = TextEditingController(text: initialValue);
    _lastTexts[key] = initialValue ?? '';

    void listener() => _onChanged(key);
    controller.addListener(listener);

    _controllers[key] = controller;
    _listeners[key] = listener;

    if (debounceDuration != null) {
      _debounceDurations[key] = debounceDuration;
    }
    final focusNode = FocusNode();
    if (withFocusNodes) {
      _focusNodes[key] = focusNode;
    }
  }

  /// Internal method that disposes the controller and related resources for the given [key].
  ///
  /// This method:
  /// * Cancels any pending debounce timers
  /// * Removes and disposes the controller listener
  /// * Removes all related entries from internal maps
  void _disposeController(K key) {
    final controller = _controllers[key];
    final listener = _listeners[key];

    _debounceTimers[key]?.cancel();

    if (controller != null && listener != null) {
      controller.removeListener(listener);
      controller.dispose();
    }

    _controllers.remove(key);
    _listeners.remove(key);
    _debounceTimers.remove(key);
    _debounceDurations.remove(key);
    _lastTexts.remove(key);
  }

  /// Internal method that disposes the focus node for the given [key].
  ///
  /// Safely disposes the [FocusNode] if it exists.
  void _disposeFocusNode(K key) {
    final focusNode = _focusNodes[key];
    focusNode?.dispose();
  }

  /// Initializes controllers for the specified [keys].
  ///
  /// This is the primary method to set up form field controllers. Call this
  /// method in your [State.initState] method.
  ///
  /// Parameters:
  /// * [keys] - The collection of keys to initialize controllers for
  /// * [debounceDuration] - Global debounce duration for all fields
  /// * [perKeyDebounce] - Map of custom debounce durations per field key
  /// * [initialValues] - Map of initial text values per field key
  /// * [withFocusNode] - If `true`, creates [FocusNode]s for focus management
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   initControllers(
  ///     FormField.values,
  ///     debounceDuration: Duration(milliseconds: 500),
  ///     perKeyDebounce: {
  ///       FormField.search: Duration(milliseconds: 800),
  ///     },
  ///     initialValues: {
  ///       FormField.email: 'user@example.com',
  ///     },
  ///     withFocusNode: true,
  ///   );
  /// }
  /// ```
  void initControllers(
    Iterable<K> keys, {
    Duration? debounceDuration,
    Map<K, Duration>? perKeyDebounce,
    Map<K, String>? initialValues,
    bool withFocusNode = false,
  }) {
    for (final k in keys) {
      _initController(
        k,
        initialValue: initialValues?[k],
        debounceDuration: perKeyDebounce?[k] ?? debounceDuration,
        withFocusNodes: withFocusNode,
      );
    }
  }

  /// Disposes all text editing controllers and their listeners.
  ///
  /// This method is automatically called in the mixin's [dispose] method,
  /// but can be called manually if needed. It will:
  /// * Cancel all pending debounce timers
  /// * Remove all controller listeners
  /// * Dispose all controllers
  /// * Clear all internal maps
  void disposeControllers() {
    for (final k in _controllers.keys.toList()) {
      _disposeController(k);
    }
  }

  /// Disposes all focus nodes.
  ///
  /// This method is automatically called in the mixin's [dispose] method,
  /// but can be called manually if needed.
  void disposeFocusNodes() {
    for (final k in _focusNodes.keys.toList()) {
      _disposeFocusNode(k);
    }
  }

  @override
  void dispose() {
    disposeControllers();
    disposeFocusNodes();
    super.dispose();
  }

  /// Sets a custom debounce duration for a specific field.
  ///
  /// Parameters:
  /// * [key] - The key identifying the field
  /// * [duration] - The new debounce duration to apply
  ///
  /// This duration will be used for future text changes on this field.
  void setDebounceDuration(K key, Duration duration) {
    _debounceDurations[key] = duration;
  }

  /// Callback method that is triggered immediately when a field's text changes.
  ///
  /// Override this method to handle immediate text changes without debouncing.
  /// This is useful for real-time validation or UI updates.
  ///
  /// Parameters:
  /// * [key] - The key identifying the field that changed
  /// * [value] - The new text value
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void onFieldChanged(FormField key, String value) {
  ///   if (key == FormField.email) {
  ///     setState(() {
  ///       isEmailValid = value.contains('@');
  ///     });
  ///   }
  /// }
  /// ```
  void onFieldChanged(K key, String value) {}

  /// Callback method that is triggered after the debounce duration has elapsed.
  ///
  /// Override this method to handle expensive operations like API calls,
  /// database queries, or complex validations that should only occur
  /// after the user has stopped typing.
  ///
  /// Parameters:
  /// * [key] - The key identifying the field that changed
  /// * [value] - The final debounced text value
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void onFieldDebounced(FormField key, String value) {
  ///   if (key == FormField.search) {
  ///     performSearch(value);
  ///   }
  /// }
  /// ```
  void onFieldDebounced(K key, String value) {}

  /// Requests focus for the field with the given [key].
  ///
  /// This will make the field active and show the keyboard on mobile devices.
  /// Does nothing if no [FocusNode] exists for the key.
  ///
  /// Parameters:
  /// * [key] - The key identifying the field to focus
  ///
  /// Example:
  /// ```dart
  /// // Focus the email field after validation fails
  /// if (!isEmailValid) {
  ///   requestFocus(FormField.email);
  /// }
  /// ```
  void requestFocus(K key) {
    final focusNode = _focusNodes[key];
    focusNode?.requestFocus();
  }

  /// Normalizes the text selection position for a field.
  ///
  /// This method ensures that the selection cursor position doesn't exceed
  /// the text length. This can happen after programmatically setting text.
  ///
  /// Parameters:
  /// * [key] - The key identifying the field to normalize
  ///
  /// The selection will be moved to the end of the text if it's out of bounds.
  void normalizeSelection(K key) {
    final controller = _controllers[key];
    if (controller == null) return;
    final textLength = controller.text.length;
    final selection = controller.selection;
    if (selection.start > textLength || selection.end > textLength) {
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: textLength),
      );
    }
  }

  /// Removes focus from the field with the given [key].
  ///
  /// This will dismiss the keyboard on mobile devices and deactivate the field.
  /// Does nothing if no [FocusNode] exists for the key.
  ///
  /// Parameters:
  /// * [key] - The key identifying the field to unfocus
  ///
  /// Example:
  /// ```dart
  /// // Unfocus the password field after validation
  /// unFocus(FormField.password);
  /// ```
  void unFocus(K key) {
    final focusNode = _focusNodes[key];
    focusNode?.unfocus();
  }
}

/// Private extension on nullable [String] for internal use.
///
/// Provides utility methods for checking if a string is null or blank.
extension on String? {
  /// Checks if this string is null or contains only whitespace.
  ///
  /// Returns `true` if:
  /// * The string is `null`
  /// * The string is empty after trimming whitespace
  ///
  /// Returns `false` otherwise.
  bool isNullOrBlank() => this == null || this!.trim().isEmpty;
}
