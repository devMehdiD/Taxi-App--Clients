import 'package:flutter/material.dart';

Widget circularProgress(String message) => Dialog(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SizedBox(
          height: 100,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message),
              const SizedBox(
                width: 10,
              ),
              const CircularProgressIndicator()
            ],
          ),
        ),
      ),
    );
Widget showDailognotifuction(String locationStart, locationEnd, String name) =>
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SizedBox(
          height: 300,
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Text(name),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("From $locationStart"),
                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "To $locationStart",
                  ),
                  const Icon(
                    Icons.location_on,
                    color: Colors.green,
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red)),
                    onPressed: () {},
                    child: const Text("Cancel")),
                ElevatedButton(onPressed: () {}, child: const Text("Accepte")),
              ])
            ],
          ),
        ),
      ),
    );
