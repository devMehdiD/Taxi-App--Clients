// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:uberclient/widget/circularprogress.dart';

import 'home.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  TextEditingController name = TextEditingController();
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
                controller: name,
                decoration: InputDecoration(
                  hintText: "Name",
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
                onPressed: () async {
                  await signup();
                },
                child: const Text("Login")),
            const SizedBox(height: 20),
            TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Login()));
                },
                child: const Text("have account login ?"))
          ],
        ),
      )),
    );
  }

  signup() async {
    showDialog(
        context: context, builder: (_) => circularProgress("Procesing ..."));
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      )
          .then((value) async {
        dynamic token = await FirebaseMessaging.instance.getToken();
        Map<String, dynamic> infouser = {
          "id": value.user!.uid,
          'email': email.text.trim(),
          'name': name.text.trim(),
          'token': token,
          'lat': 0,
          'long': 0
        };
        FirebaseFirestore.instance
            .collection("client")
            .doc(value.user!.uid)
            .set(infouser);
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const Home()), (route) => false);
      });
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showDialog(
            context: context,
            builder: (_) =>
                circularProgress('The password provided is too weak.'));
      } else if (e.code == 'email-already-in-use') {
        showDialog(
            context: context,
            builder: (_) => circularProgress(
                ('The account already exists for that email.')));
      }
    } catch (e) {
      print(e);
    }
  }
}
