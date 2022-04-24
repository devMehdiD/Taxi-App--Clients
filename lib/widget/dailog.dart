import 'package:flutter/material.dart';

Widget showLoading(
  double secondTue,
  String message,
  voidCallback,
) =>
    Container(
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          const Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: LinearProgressIndicator(
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation(Colors.red),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            message.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: 20,
          ),
          secondTue < 10
              ? Text(
                  "00:0${secondTue.toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.white),
                )
              : Text(
                  "00:${secondTue.toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
