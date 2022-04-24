import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uberclient/stateMangment/providerstate.dart';
import 'package:uberclient/widget/container_blacK.dart';
import 'package:uberclient/widget/dailog.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  String titel = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      UberStateManegment uberStateManegment =
          Provider.of<UberStateManegment>(context, listen: false);
      await uberStateManegment.determinePosition();
      await uberStateManegment.getAllDrivers();
      await uberStateManegment.updatePostion();
      await uberStateManegment.lesnerToStatus();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<UberStateManegment>(context);
    final size = MediaQuery.of(context).size;
    CameraPosition cameraPosition = const CameraPosition(
        target: LatLng(
          37.42796133580664,
          -122.085749655962,
        ),
        zoom: 19);
    return Scaffold(
      body: Stack(children: [
        Positioned(
            height: size.height * 0.7,
            left: 0,
            right: 0,
            child: Center(
              child: prov.serviceEnabled
                  ? GoogleMap(
                      myLocationButtonEnabled: true,
                      initialCameraPosition: cameraPosition,
                      mapType: MapType.normal,
                      markers: prov.marker,
                      onMapCreated: (GoogleMapController controller) {
                        prov.controller.complete(controller);
                      },
                      onTap: (latlang) async {
                        prov.addMarker(latlang);
                      },
                    )
                  : Center(
                      child: TextButton(
                          onPressed: () {
                            prov.determinePosition();
                          },
                          child: const Text("Pleaz Enable Your Location")),
                    ),
            )),
        Positioned(
            top: 30,
            left: 20,
            child: Builder(builder: (context) {
              return IconButton(
                  onPressed: () async {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(Icons.menu));
            })),
        Positioned(
            height: size.height * 0.3,
            bottom: 0,
            left: 0,
            right: 0,
            child: prov.showTimer
                ? Container(
                    child: showLoading(
                        prov.seconsTue, prov.message, prov.incrementTimer),
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        )))
                : buildRequistUi(context))
      ]),
      drawer: const Drawer(),
    );
  }
}
