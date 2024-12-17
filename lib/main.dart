import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:macabulos_etr/firebase_options.dart';
import 'package:macabulos_etr/screens/loginscreen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:macabulos_etr/consts.dart';

void main() async {
  await _setup();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripePublishableKey;
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
