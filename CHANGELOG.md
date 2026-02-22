# Changelog

All notable changes to this project will be documented in this file.

## [1.0.2] - 2026-01-22
* Added comprehensive example project in `/example` folder
* Updated documentation in README.md 

## [1.0.1] - 2026-01-22
* Fixed minor typo in documentation

## [1.0.0] - 2026-01-21

### 🎉 Initial Release

#### Features
* **MultiFormFieldsMixin** - Core mixin for managing multiple form fields
  * Automatic TextEditingController creation and disposal
  * Automatic FocusNode management
  * Type-safe form field keys (supports enums, strings, and any comparable type)

* **Debouncing Support**
  * Global debounce duration configuration (default 600ms)
  * Per-field custom debounce durations
  * Separate callbacks for immediate (`onFieldChanged`) and debounced (`onFieldDebounced`) events

* **Focus Management**
  * `requestFocus()` - Programmatically focus on any field
  * `unFocus()` - Remove focus from a field
  * `hasFocus()` - Check if a field has focus
  * Automatic FocusNode lifecycle management

* **Text Control**
  * `getText()` - Get current text value (returns null if empty)
  * `setText()` - Set text programmatically with optional callback triggering
  * `getController()` - Access underlying TextEditingController
  * Initial values support during initialization

* **MultiFormScope**
  * InheritedWidget for sharing form state across widget tree
  * Context extension for easy access: `context.multipleForm<K, W>()`
  * Perfect for breaking down large forms into smaller components

* **FormKey Utility**
  * Type-safe wrapper class for form field keys
  * Optional alternative to using enums


---

## Future Plans

### [1.1.0] - Planned
* Form validation helpers
* Error message management
* Form state persistence


---

For more information, visit [GitHub Repository](https://github.com/AbbosbekBotirjonovich/multi_form_fields)
