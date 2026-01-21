# Multi Form Fields

A powerful Flutter package for managing multiple form fields with built-in debouncing, focus control, and state management. Simplify your form handling with automatic text controller and focus node management.

## Features

✨ **Automatic Controller Management** - No need to manually create and dispose TextEditingControllers  
⏱️ **Built-in Debouncing** - Configurable debounce timers for text input (perfect for search fields and API calls)  
🎯 **Focus Management** - Easy focus control with automatic FocusNode handling  
🔑 **Type-Safe Keys** - Use enums, strings, or any type as field identifiers  
🎨 **Flexible & Lightweight** - Minimal boilerplate, maximum productivity  
♻️ **Automatic Cleanup** - Controllers and focus nodes are automatically disposed  
🔄 **Real-time & Debounced Callbacks** - Handle both immediate and delayed text changes

## Getting started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  multi_form_fields: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Example

Here's a simple example with an email and password form:

```dart
import 'package:flutter/material.dart';
import 'package:multi_form_fields/multi_form_fields.dart';

// Define your form field keys using an enum
enum FormField { email, password }

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with MultiFormFieldsMixin<FormField, LoginForm> {
  
  @override
  void initState() {
    super.initState();
    // Initialize controllers for all fields
    initControllers(
      FormField.values,
      withFocusNode: true, // Enable focus management
    );
  }

  @override
  void onFieldChanged(FormField key, String value) {
    // Called immediately when text changes
    print('$key changed to: $value');
  }

  @override
  void onFieldDebounced(FormField key, String value) {
    // Called after user stops typing (default 600ms)
    print('$key debounced: $value');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: getController(FormField.email),
          focusNode: getFocusNode(FormField.email),
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: getController(FormField.password),
          focusNode: getFocusNode(FormField.password),
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
      ],
    );
  }
}
```

### Advanced Example with Custom Debounce

```dart
enum SearchField { query, filters, category }

class SearchFormState extends State<SearchForm>
    with MultiFormFieldsMixin<SearchField, SearchForm> {
  
  @override
  void initState() {
    super.initState();
    initControllers(
      SearchField.values,
      debounceDuration: const Duration(milliseconds: 500), // Global debounce
      perKeyDebounce: {
        // Custom debounce per field
        SearchField.query: const Duration(milliseconds: 800),
      },
      initialValues: {
        // Set initial values
        SearchField.category: 'All',
      },
      withFocusNode: true,
    );
  }

  @override
  void onFieldDebounced(SearchField key, String value) {
    if (key == SearchField.query && value.isNotEmpty) {
      // Perform search API call
      performSearch(value);
    }
  }

  void performSearch(String query) {
    // Your search logic here
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: getController(SearchField.query),
      focusNode: getFocusNode(SearchField.query),
      decoration: const InputDecoration(
        labelText: 'Search',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
```

### Using MultiFormScope for Shared State

Share form state across multiple widgets using `MultiFormScope`:

```dart
class ParentWidget extends StatefulWidget {
  @override
  State<ParentWidget> createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget>
    with MultiFormFieldsMixin<FormField, ParentWidget> {
  
  @override
  void initState() {
    super.initState();
    initControllers(FormField.values, withFocusNode: true);
  }

  @override
  Widget build(BuildContext context) {
    return MultiFormScope<FormField, ParentWidget>(
      mixin: this,
      child: Column(
        children: [
          EmailField(),
          PasswordField(),
          SubmitButton(),
        ],
      ),
    );
  }
}

// Child widget accessing the form state
class EmailField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final form = context.multipleForm<FormField, ParentWidget>();
    
    return TextField(
      controller: form.getController(FormField.email),
      focusNode: form.getFocusNode(FormField.email),
      decoration: const InputDecoration(labelText: 'Email'),
    );
  }
}
```

### Programmatically Control Fields

```dart
// Set text without triggering callbacks
setText(FormField.email, 'user@example.com', notify: false);

// Set text and trigger callbacks
setText(FormField.email, 'user@example.com', notify: true);

// Get current text value
final email = getText(FormField.email);

// Focus management
requestFocus(FormField.email);
unFocus(FormField.email);

// Check focus state
if (hasFocus(FormField.email)) {
  print('Email field has focus');
}

// Change debounce duration dynamically
setDebounceDuration(
  FormField.search,
  const Duration(milliseconds: 1000),
);
```

## API Reference

### MultiFormFieldsMixin

Main mixin that provides form field management capabilities.

#### Methods

- `initControllers()` - Initialize controllers for specified keys
- `getController(K key)` - Get TextEditingController for a field
- `getFocusNode(K key)` - Get FocusNode for a field
- `getText(K key)` - Get current text value (returns null if empty)
- `setText(K key, String text, {bool notify})` - Set text programmatically
- `hasController(K key)` - Check if controller exists
- `hasFocusNode(K key)` - Check if focus node exists
- `hasFocus(K key)` - Check if field has focus
- `requestFocus(K key)` - Request focus for a field
- `unFocus(K key)` - Remove focus from a field
- `setDebounceDuration(K key, Duration duration)` - Set custom debounce duration
- `disposeControllers()` - Manually dispose all controllers
- `disposeFocusNodes()` - Manually dispose all focus nodes

#### Callbacks

- `onFieldChanged(K key, String value)` - Called immediately on text change
- `onFieldDebounced(K key, String value)` - Called after debounce delay

#### Properties

- `defaultDebounce` - Default debounce duration (600ms)

### MultiFormScope

InheritedWidget for sharing form state across the widget tree.

```dart
MultiFormScope<KeyType, WidgetType>(
  mixin: formMixin,
  child: YourWidget(),
)
```

Access via:
```dart
context.multipleForm<KeyType, WidgetType>()
```

### FormKey

Type-safe wrapper for form field keys (optional utility class).

```dart
const emailKey = FormKey('email');
const passwordKey = FormKey('password');
```

## Best Practices

1. **Use Enums for Field Keys** - Enums provide type safety and better IDE support
2. **Set Initial Values in initControllers** - Avoid setting text in build method
3. **Use notify: false When Setting Text** - Prevent unnecessary callbacks when programmatically updating fields
4. **Leverage Debouncing for API Calls** - Use `onFieldDebounced` for expensive operations
5. **Clean Focus Management** - Always initialize with `withFocusNode: true` if you need focus control

## Common Use Cases

- 🔍 **Search Forms** - Debounced search with real-time results
- 📝 **Multi-step Forms** - Manage complex forms with many fields
- ✅ **Form Validation** - Real-time validation with debounced API checks
- 💬 **Chat Interfaces** - Text input with focus management
- 🎨 **Dynamic Forms** - Forms with conditional fields

## Additional Information

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Issues

If you encounter any issues or have feature requests, please file them on the [GitHub issues page](https://github.com/AbbosbekBotirjonovich/multi_form_fields/issues).

### License

This project is licensed under the MIT License - see the LICENSE file for details.

### Author

Developed by Abbosbek Botirjonovich.
