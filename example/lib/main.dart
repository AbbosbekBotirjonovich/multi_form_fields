import 'package:flutter/material.dart';
import 'package:multi_form_fields/multi_form_fields.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MultiFormFields Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

enum LoginFormFields { email, password }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with MultiFormFieldsMixin<LoginFormFields, MyHomePage> {
  String _status = 'Idle';

  @override
  void initState() {
    super.initState();
    // Initialize controllers and focus nodes for all fields in the enum
    initControllers(
      LoginFormFields.values,
      withFocusNode: true,
      perKeyDebounce: {
        LoginFormFields.email: const Duration(milliseconds: 1000),
      },
    );
  }

  @override
  void onFieldChanged(LoginFormFields key, String value) {
    setState(() {
      _status = 'Typing in ${key.name}...';
    });
  }

  @override
  void onFieldDebounced(LoginFormFields key, String value) {
    setState(() {
      _status = 'Debounced ${key.name}: $value';
    });
  }

  void _login() {
    final email = getText(LoginFormFields.email);
    final password = getText(LoginFormFields.password);

    if (email == null || password == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _status = 'Logging in with $email...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MultiFormFields Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: getController(LoginFormFields.email),
              focusNode: getFocusNode(LoginFormFields.email),
              decoration: const InputDecoration(
                labelText: 'Email (1s debounce)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: getController(LoginFormFields.password),
              focusNode: getFocusNode(LoginFormFields.password),
              decoration: const InputDecoration(
                labelText: 'Password (default 600ms debounce)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => requestFocus(LoginFormFields.email),
              child: const Text('Focus Email'),
            ),
            TextButton(
              onPressed: () => setText(LoginFormFields.email, 'test@example.com', notify: true),
              child: const Text('Set Email Programmatically'),
            ),
          ],
        ),
      ),
    );
  }
}
