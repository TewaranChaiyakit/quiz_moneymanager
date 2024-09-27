import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quiz_money_manager/screen/signin_screen.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // เลือกการตั้งค่าตาม platform
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Income Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SigninScreen(),  // Start with Sign In screen
    );
  }
}
