import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase manually with explicit options to bypass native file lookup errors
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY", // Replace with your actual Firebase API Key
        appId: "YOUR_APP_ID",     // Replace with your actual Firebase App ID
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID", // Replace with Sender ID
        projectId: "YOUR_PROJECT_ID", // Replace with your Firebase Project ID
      ),
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(const TrustEscrowApp());
}

class TrustEscrowApp extends StatelessWidget {
  const TrustEscrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('TrustEscrow')),
        body: const Center(
          child: Text(
            'App & Manual Firebase Initialized Successfully!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
