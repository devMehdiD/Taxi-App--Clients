import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uberclient/signup.dart';
import 'package:uberclient/stateMangment/providerstate.dart';

import 'home.dart';

bool islogin = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (FirebaseAuth.instance.currentUser != null) {
    islogin = true;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UberStateManegment>(
      create: (context) => UberStateManegment(),
      builder: (context, widget) => MaterialApp(
        home: islogin ? const Home() : const SignUp(),
      ),
    );
  }
}
