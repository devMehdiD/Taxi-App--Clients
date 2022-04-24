import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uberclient/widget/circularprogress.dart';

import 'home.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Image.network(
                "https://thumbs.dreamstime.com/b/male-driver-driving-smile-173901481.jpg",
                height: 150,
                width: 200,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
                controller: email,
                decoration: InputDecoration(
                  hintText: "Email",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                )),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
                controller: password,
                decoration: InputDecoration(
                  hintText: "Password",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                )),
            ElevatedButton(
                onPressed: () {
                  loginwith();
                },
                child: const Text("Login"))
          ],
        ),
      )),
    );
  }

  loginwith() async {
    showDialog(
        context: context, builder: (_) => circularProgress("Procecing ..."));
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.text.trim(), password: password.text.trim())
          .then((value) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
            (route) => false);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // ignore: avoid_print
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        // ignore: avoid_print
        print('Wrong password provided for that user.');
      }
    }
  }
}
