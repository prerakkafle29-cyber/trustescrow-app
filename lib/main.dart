import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DiagnosticApp());
}

class DiagnosticApp extends StatelessWidget {
  const DiagnosticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DiagnosticScreen(),
    );
  }
}

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  String _status = 'Starting Firebase.initializeApp()...';

  @override
  void initState() {
    super.initState();
    _testFirebaseCore();
  }

  Future<void> _testFirebaseCore() async {
    try {
      // Step A: Check if binding is alive
      setState(() { _status = 'Binding OK. Calling Firebase.initializeApp()...'; });
      
      FirebaseApp app = await Firebase.initializeApp();
      
      setState(() {
        _status = 'SUCCESS!\nFirebase initialized: ${app.name}';
      });
    } catch (e, stack) {
      setState(() {
        _status = 'CAUGHT EXCEPTION:\n$e\n\nSTACKTRACE:\n$stack';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Diagnostic')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            _status,
            style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }
}
