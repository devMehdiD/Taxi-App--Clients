// ignore: file_names
// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uberclient/widget/dailog.dart';

import '../stateMangment/providerstate.dart';

Widget buildRequistUi(context) {
  final prov = Provider.of<UberStateManegment>(context);
  return Container(
    decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    child: Column(
      children: [
        TextFormField(
          controller: prov.locationcontroller,
          enabled: false,
          decoration: InputDecoration(
              hintText: prov.locationcontroller.text.isNotEmpty
                  ? prov.locationcontroller.text
                  : ".....",
              hintStyle: const TextStyle(color: Colors.white),
              prefixIcon: const Icon(
                Icons.location_on,
                color: Colors.green,
              )),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(
          height: 20,
        ),
        TextFormField(
          controller: prov.goTo,
          enabled: false,
          decoration: InputDecoration(
              hintText: prov.goTo.text.isNotEmpty ? prov.goTo.text : "Go To ?",
              hintStyle: const TextStyle(color: Colors.white),
              prefixIcon: const Icon(
                Icons.location_on,
                color: Colors.green,
              )),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(
          height: 10,
        ),
        Flexible(
          child: FutureBuilder(
            future: prov.driver,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return PageView.builder(
                    onPageChanged: prov.onChanged,
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.docs[prov.selctedIndex];
                      prov.addToVaribles(
                          data['name'], data['lat'], data['long'], data['id']);
                      return ListTile(
                        title: Text(
                          snapshot.data!.docs[index]['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        leading: const Icon(
                          Icons.drive_eta_rounded,
                          color: Colors.green,
                        ),
                        trailing: const Text(
                          "\$ 33",
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    });
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
            onPressed: prov.goTo.text.isEmpty
                ? null
                : () {
                    try {
                      prov.sendRequist(
                          driverName: prov.drName,
                          driverId: prov.drId.toString(),
                          clientId: prov.auth.toString(),
                          fromlocation: prov.locationcontroller.text,
                          tolocation: prov.goTo.text,
                          clientName: prov.clName.toString(),
                          latClient: prov.latitudeClinet,
                          longClient: prov.longitudeClinet,
                          latDriver: prov.drLat,
                          longDriver: prov.drLong);

                      prov.incrementTimer();
                    } catch (e) {
                      print("$e");
                    }
                  },
            child: Text(
              "Confirm",
              style: TextStyle(color: Colors.white),
            ))
      ],
    ),
  );
}
