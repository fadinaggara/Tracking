import 'dart:ui';
import 'dart:math' show cos, sqrt, asin;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hadil_project/Screens/Login.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geocod;
import 'package:fluttertoast/fluttertoast.dart';

import 'package:awesome_notifications/awesome_notifications.dart';



/// get response from OSM
class NetworkHelper {
  NetworkHelper(
      {required this.sLat,
      required this.sLng,
      required this.eLat,
      required this.eLng});

  final String url = 'https://api.openrouteservice.org/v2/directions/';
  final String apiKey =
      '5b3ce3597851110001cf6248cc1a4f9513c240db9f9b1752093f1ddc';
  final String journeyMode =
      'foot-walking'; // Change it if you want or make it variable
  final double sLat;
  final double sLng;
  final double eLat;
  final double eLng;

  /// send request to osm
  Future getData() async {
    http.Response response = await http.get(Uri.parse(
        '$url$journeyMode?api_key=$apiKey&start=$sLng,$sLat&end=$eLng,$eLat'));
    print(
        "### Url used ==> $url$journeyMode?$apiKey&start=$sLat,$sLng&end=$eLat,$eLng");
    if (response.statusCode == 200) {
      //succed
      String data = response.body;

      return jsonDecode(data);
    } else {
      print('respons code => ${response.statusCode}');
    }
  }
}

class LineString {
  LineString(this.lineString);

  List<dynamic> lineString;
}

///OSM***********
class OSM1 extends StatefulWidget {
  @override
  _OSM1State createState() => _OSM1State();
}

class _OSM1State extends State<OSM1> {
  final addressController = TextEditingController();

  /// polylines
  var data;
  final List<LatLng> exportedPath = [];

  /// exported path black
  final List<LatLng> routePolys = [];

  /// path li mzel (gps => dest) purple
  final List<LatLng> walkedRoutePolys = [];

  /// path li mcheh (awl pt => gps) green
  double distanceToWalk = 0.0;
  double distanceWalked = 0.0;
  bool typing = false;
  double gpsLat = 0.0;
  double gpsLng = 0.0;
  double endLat = 35.835569;
  double endLng = 10.595069;
  bool hasLocations = false;
  int secToReloadRoute = 0;
  int secToSaveGps = 0;
  int gpsIsActive = 0;
  String pathName = '';
  final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();
  final TextEditingController pathController = TextEditingController();
  double initZoom = 10.0;
  Timer _timer = Timer.periodic(Duration(seconds: 1), (_) {});

  /// dest Marker  decla
  Marker destMarker = Marker(
    rotate: true,
    width: 0.0,
    height: 0.0,
    point: LatLng(35.835569, 10.595069),
    builder: (ctx) => Container(),
  );

  /// gps marker decla
  Marker gpsMarker = Marker(
    rotate: true,
    width: 0.0,
    height: 0.0,
    point: LatLng(0.0, 0.0),
    builder: (ctx) => Container(),
  );

  /// Converting.. { Coords <= Adress }
  void _getLatLngFromAdress(String? pAddress) async {
    try {
      List<geocod.Location> newPos =
          await geocod.locationFromAddress(pAddress ?? '');
      geocod.Location adressMark = newPos[0];

      endLat = adressMark.latitude;
      endLng = adressMark.longitude;
      Marker destMar = Marker(
        rotate: true,
        width: 80.0,
        height: 80.0,
        point: LatLng(endLat, endLng),
        builder: (ctx) => Container(
          child: Icon(
            Icons.place,
            color: Colors.blueAccent,
            size: 25,
          ),
        ),
      );
      if (mounted) {
        setState(() {
          destMarker = destMar;
        });
      }
      print(
          '#### Destination at => ${destMarker.point.latitude} _ ${destMarker.point.longitude}');
      Fluttertoast.showToast(
          msg: "address found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
      _mapController.move(LatLng(endLat, endLng), 16.0);
      addressController.text = '';
    }

    ///when no address understandable
    on Exception catch (e) {
      Fluttertoast.showToast(
          msg: "no address found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  /// Converting.. { Coords => Adress }
  Future<String> _getAdressFromLatLng(double? pLat, double? pLng) async {
    String localAdress = 'no address';
    List<geocod.Placemark> newPlace =
        await geocod.placemarkFromCoordinates(pLat ?? 0.0, pLng ?? 0.0);
    geocod.Placemark placeMark = newPlace[0];

    String? name = placeMark.name;
    String? subLocality = placeMark.subLocality;
    String? locality = placeMark.locality;
    String? administrativeArea = placeMark.administrativeArea;
    String? postalCode = placeMark.postalCode;
    String? street = placeMark.street;

    localAdress =
        '${street}, ${locality}, ${administrativeArea}, ${postalCode}';
    return localAdress;
  }

  @override
  void initState() {
    super.initState();
    checkLocation();

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> AlertNotif() async {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 10,
      channelKey: 'basic_channel',
      title: 'you are in in desired location',
    ));
  }

  void detectIfInRange(double d) {
    if (d > 1.0 && d < 20.0) {
      AlertNotif();
    }
  }

  ///Timer
  void startTimer() {
    // if gps stopped
    if (gpsIsActive == 0) {
      Fluttertoast.showToast(
          msg: "gps activated",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      /// each X(1) sec update_gps >> TimeToUpdateGps
      _timer = Timer.periodic(Duration(seconds: 1), (t) {
        distanceToWalk = calculDist(routePolys); //km
        distanceWalked = calculDist(walkedRoutePolys); //km

        print(('/// dis to walk = $distanceToWalk'));
        print(('/// dis  walked = $distanceWalked'));

        ///camera follow gps
        _mapController.move(LatLng(gpsLat, gpsLng), 16.0);

        /// each X(5) sec update_path >> TimeToUpdatePath
        if (secToReloadRoute >= 5) {
          drawPath();
          detectIfInRange(distanceToWalk);
          secToReloadRoute = 0;
        } else {
          secToReloadRoute++;
        }

        /// each X(3) sec save_gps_location >> TimeToSaveGpsPoint
        if (secToSaveGps >= 3) {
          saveCurrLoc();
          secToSaveGps = 0;
          //print('#### Route Reloaded ${DateTime.now()}');
        } else {
          secToSaveGps++;
        }

        /// get the current gps loaction from fire base each 1 sec
        gpsLcation();

        print('### Timer Running ....');
      });
    } else {
      // if gps activated
      Fluttertoast.showToast(
          msg: "gps already activated",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void endTimer() {
    if (gpsIsActive == 1) {
      Fluttertoast.showToast(
          msg: "gps stopped",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0);
      print('### End Timer');
      _timer.cancel();
    } else {
      Fluttertoast.showToast(
          msg: "gps already stopped",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  //////////////////// disposee //////////////////////
  @override
  void dispose() {
    print('### End Timer');

    _timer.cancel();
    super.dispose();
  }

  /////////////////////////////// ////////////////////////

  //calcul disatance
  double calculDist(List<LatLng> polyline) {
    double totalDistance = 0;

    if (polyline.isNotEmpty) {
      double calculateDistance(lat1, lon1, lat2, lon2) {
        var p = 0.017453292519943295;
        var c = cos;
        var a = 0.5 -
            c((lat2 - lat1) * p) / 2 +
            c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
        return 12742 * asin(sqrt(a));
      }

      for (var i = 0; i < polyline.length - 1; i++) {
        totalDistance += calculateDistance(
            polyline[i].latitude,
            polyline[i].longitude,
            polyline[i + 1].latitude,
            polyline[i + 1].longitude);
      }

      print('#### distance= $totalDistance');
    }

    return totalDistance;
  }

  Future<void> signOut() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.signOut();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void gpsLcation() async {
    DatabaseReference gpsRef =
        FirebaseDatabase.instance.ref().child('/allData/gps/');
    final snapshot = await gpsRef.get();
    var data = Map<String, dynamic>.from(snapshot.value as Map);
    var _lat = data["lat"];
    var _lng = data["lng"];

    if (this.mounted) {
      setState(() {
        gpsLat = double.parse(_lat);
        gpsLng = double.parse(_lng);
        gpsMarker = Marker(
          rotate: true,
          width: 80.0,
          height: 80.0,
          point: LatLng(gpsLat, gpsLng),
          builder: (ctx) => Container(
            child: Icon(
              Icons.place,
              color: Colors.red,
              size: 25,
            ),
          ),
        );
        print('########### Gps Position from DB => $gpsLat _ $gpsLng');
      });
    }
  }

  void switchGps(String value) async {
    DatabaseReference activeModeRef0 =
        FirebaseDatabase.instance.ref('/allData/');
    await activeModeRef0.update({
      "activeMode": '$value',
    });
    DatabaseReference activeModeRef =
        FirebaseDatabase.instance.ref('/allData/activeMode');
    final snapshot = await activeModeRef.get();
    if (this.mounted) {
      setState(() {
        gpsIsActive = int.parse(snapshot.value.toString());
      });
    }
    print('gpsIsActive = $gpsIsActive');
  }

  void drawPath() async {
    NetworkHelper network = NetworkHelper(
      sLat: gpsLat,
      sLng: gpsLng,
      eLat: endLat,
      eLng: endLng,
    );

    try {
      //print('###### TRY getting network data');
      /// save all point between (gps-dest) to Raw Data
      data = await network.getData(); //json Decoded data

      ///  routePolys => list of type <Latlng> holding point betwwen (gps-dest)
      routePolys.clear();

      // We can reach to our desired JSON data manually as following
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      /// depends on json forma //coordinates=lat & lng of all point

      // list of coordinates of all points
      /// save all points to from Json Row Data to routePolys List
      for (int i = 0; i < ls.lineString.length; i++) {
        routePolys.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }
      print('###### routePolys length => ${routePolys.length}');
    } catch (e) {
      print('### EXEP: $e');
    }
  } // if 404 check the dest & gps markers they should be in readable positions

  void saveCurrLoc() {
    LatLng newCurrLoc = LatLng(gpsLat, gpsLng);

    if (walkedRoutePolys.isNotEmpty) {
      if (walkedRoutePolys.last != newCurrLoc) {
        walkedRoutePolys.add(newCurrLoc);

        print('######## added new curr Loc}');
      }
    } else {
      walkedRoutePolys.add(newCurrLoc);
      print('######## added new curr Loc at first');
    }
    print('######## walkedRoutePolys Length=> ${walkedRoutePolys.length}');
  } // update walkedPolyline(green) each 5 sec ,if gps is moving it doesn't

  void exportLastDest(String lat, String lng) {
    endLat = double.parse(lat);
    endLng = double.parse(lng);

    // create dest marker
    Marker destMar = Marker(
      rotate: true,
      width: 80.0,
      height: 80.0,
      point: LatLng(endLat, endLng),
      builder: (ctx) => Container(
        child: Icon(
          Icons.place,
          color: Colors.blueAccent,
          size: 25,
        ),
      ),
    );
    if (this.mounted) {
      setState(() {
        destMarker = destMar;
      });
    }
  }

  void exportLastPath(String pName) async {
    print('#####should export');
    DatabaseReference gpsRef =
        FirebaseDatabase.instance.ref('/allData/paths/$pathName');
    final snapshot = await gpsRef.get();
    var data = Map<String, dynamic>.from(snapshot.value as Map);

    print('#####should export= $data');

    exportedPath.clear(); //black

    data.entries.forEach((e) => exportedPath.add(
        LatLng(double.parse(e.value['lat']), double.parse(e.value['lng']))));
  }

  void save() {
    saveLastMarkerToFb(
        gpsLat.toString(), gpsLng.toString()); // SAVE DEST MARKER (blue)
    saveWalkedRouteToFb(); // save green (walked)
    checkLocation();
  }

  //save path////////////////////Savepath
  void saveWalkedRouteToFb() async {
    DatabaseReference ref0 = FirebaseDatabase.instance.ref("/allData/paths/");

    print('#### saved exportedPath $walkedRoutePolys');
    // walked from list to map

    final Map<String, Map> walkedToMap =
        {}; //////// testList ==> walked list<latlng>
    for (int i = 0; i < walkedRoutePolys.length; i++) {
      walkedToMap['${pathName}_point_$i'] = {
        'lat': walkedRoutePolys[i].latitude.toString(),
        'lng': walkedRoutePolys[i].longitude.toString(),
      };
    }

    await ref0.update({
      pathName: walkedToMap,
    });

    // walkedToMap.clear();
    walkedRoutePolys.clear();
  }

  //save destinaion
  void saveLastMarkerToFb(String lat, String lng) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("/allData/destinations");
    DateTime now = DateTime.now();
    String time = (now.hour.toString() + ":" + now.minute.toString());
    String localadress =
        await _getAdressFromLatLng(double.parse(lat), double.parse(lng));

    await ref.update({
      pathName: {
        "lat": lat,
        "lng": lng,
        'time': time,
        'address': localadress,
      }
    });
  }

  Widget savePopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Save'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("choose a name for your path"),

          /// path name input
          Form(
            key: _formKey,
            child: TextFormField(
              controller: pathController,
              decoration: InputDecoration(
                icon: Icon(Icons.place),
                hintText: 'Enter Your Path Name',
                labelText: 'Path',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Path Name cannot be empty";
                } else {
                  pathName = pathController.text;
                  pathController.text = '';

                  return null;
                }
              },
              keyboardType: TextInputType.text,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        //close btn
        MaterialButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Close'),
        ),
        // save btn
        MaterialButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              save();
              Navigator.of(context).pop();
            }
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void checkLocation() {
    DatabaseReference starCountRef = FirebaseDatabase.instance.ref('/allData');
    starCountRef.onValue.listen((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (this.mounted) {
        setState(() {
          hasLocations = snapshot.hasChild('destinations');
          //print('### hasLocations = $hasLocations');
        });
      }
    });
  } //check if there is saved destinations

  Widget lastLocationPopupDialog(BuildContext context) {
    final destinationsRef =
        FirebaseDatabase.instance.ref('/allData/destinations');
    return AlertDialog(
      title: Column(
        children: const [
          Text('last locations',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
              )),
          SizedBox(
            height: 10,
          ),
          Text('choose location to start from',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              )),
          SizedBox(
            height: 20,
          ),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              child: hasLocations
                  ? FirebaseAnimatedList(
                      defaultChild: Center(child: CircularProgressIndicator()),
                      scrollDirection: Axis.vertical,
                      query: destinationsRef,
                      padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                      itemBuilder: (
                        BuildContext context,
                        DataSnapshot snapshot,
                        Animation<double> animation,
                        int index,
                      ) {
                        return Card(
                          elevation: 10,
                          child: ListTile(
                            // export last path and dest to app
                            onTap: () {
                              exportLastDest(
                                  snapshot.child('lat').value.toString(),
                                  snapshot.child('lng').value.toString());
                              exportLastPath('${snapshot.key}');
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              '${snapshot.key}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 3.0),
                              child: Text(
                                  'time: ${snapshot.child('time').value}\naddress: ${snapshot.child('address').value}'),
                            ),
                            // delete btn
                            trailing: IconButton(
                              onPressed: () {
                                FirebaseDatabase.instance
                                    .ref(
                                        '/allData/destinations/${snapshot.key}')
                                    .remove();

                                // checkLocations(); // dont call setState with this method you have to call it inside as mfarta
                                DatabaseReference starCountRef =
                                    FirebaseDatabase.instance.ref('/allData');
                                starCountRef.onValue
                                    .listen((DatabaseEvent event) {
                                  final snapshot = event.snapshot;
                                  if (this.mounted) {
                                    setState(() {
                                      hasLocations =
                                          snapshot.hasChild('destinations');
                                      print('### hasLocations = $hasLocations');
                                    });
                                  }
                                });
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red[200],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(child: const Text('there is no locations')),
            );
          },
        ),
      ),
      actions: <Widget>[
        //close btn
        MaterialButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Close'),
        ),
      ],
    );
  }

  ///################################################################

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        toolbarHeight: 60.0,
        title: typing
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.amber[600],
                  ),
                  //margin: EdgeInsets.all(20.0),
                  alignment: Alignment.topLeft,
                  child: TextField(
                    autocorrect: true,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    controller: addressController,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        color: Colors.black38,
                        focusColor: Colors.deepOrange,
                        padding: EdgeInsets.only(left: 15.0),
                        icon: Icon(Icons.keyboard_return_sharp),
                        onPressed: () {
                          setState(() {
                            typing = false;
                          });
                        },
                      ),
                      filled: true,

                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,

                      hintText: 'address..',

                      //contentPadding: EdgeInsets.all(20.0),
                    ),
                  ),
                ),
              )
            : Text("Search for destination"),
        leading: IconButton(
          padding: EdgeInsets.only(left: 15.0),
          icon: Icon(typing ? Icons.done : Icons.search),
          onPressed: () {
            if (typing) {
              print(addressController.text);
              _getLatLngFromAdress(addressController.text);
            }
            setState(() {
              typing = !typing;
            });
          },
        ),
        actions: <Widget>[
          !typing
              ? TextButton(
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                    ),
                  ),
                  // icon: Icon(
                  //   Icons.logout,
                  //   color: Colors.white,
                  // ),
                  onPressed: () {
                    signOut();
                  },
                )
              : Container(),
        ],
      ),
      body: Stack(
        children: [
          /// display map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              interactiveFlags: InteractiveFlag.pinchZoom |
                  InteractiveFlag.drag |
                  InteractiveFlag.pinchMove |
                  InteractiveFlag.flingAnimation,

              center: LatLng(gpsLat, gpsLng),
              zoom: initZoom,

              maxZoom: 17,
              //close
              minZoom: 1,
              //far

              onLongPress: (tap, latLng) {
                endLat = latLng.latitude;
                endLng = latLng.longitude;

                // create dest marker
                Marker destMar = Marker(
                  rotate: true,
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(endLat, endLng),
                  builder: (ctx) => Container(
                    child: Icon(
                      Icons.place,
                      color: Colors.blueAccent,
                      size: 25,
                    ),
                  ),
                );
                if (this.mounted) {
                  setState(() {
                    destMarker = destMar;
                  });
                }
                print(
                    '#### Destination at => ${destMarker.point.latitude} _ ${destMarker.point.longitude}');
              },
            ),

            /// children
            children: <Widget>[
              /// map_display
              TileLayerWidget(
                options: TileLayerOptions(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  //tileProvider: NonCachingNetworkTileProvider(),
                ),
              ),

              /// path to dest (purple) changable each 5 sec
              PolylineLayerWidget(
                options: PolylineLayerOptions(
                  polylines: [
                    Polyline(
                        points: routePolys,
                        strokeWidth: 4.0,
                        color: Colors.purple),
                  ],
                ),
              ),

              /// walked_Lines green
              PolylineLayerWidget(
                options: PolylineLayerOptions(
                  polylines: [
                    Polyline(
                        points: walkedRoutePolys,
                        strokeWidth: 4.0,
                        color: Colors.green),
                  ],
                ),
              ),

              /// exported_Lines black
              PolylineLayerWidget(
                options: PolylineLayerOptions(
                  polylines: [
                    Polyline(
                        points: exportedPath,
                        strokeWidth: 4.0,
                        color: Colors.black),
                  ],
                ),
              ),

              ///markers /// gps position red
              MarkerLayerWidget(
                  options: MarkerLayerOptions(
                markers: <Marker>[
                  gpsMarker,
                ],
              )),

              ///markers /// destination blue
              MarkerLayerWidget(
                  options: MarkerLayerOptions(
                markers: <Marker>[
                  destMarker,
                ],
              )),
            ],
          ),

          ///start timer
          Positioned(
            bottom: 10,
            left: 10,
            child: FloatingActionButton.extended(
              heroTag: "start",
              label: Text('start'),
              backgroundColor: gpsIsActive == 0 ? Colors.green : Colors.grey,
              icon: Icon(
                Icons.circle,
                size: 24.0,
                color: gpsIsActive == 0 ? Colors.green[900] : Colors.grey[600],
              ),
              onPressed: () {
                switchGps('1');
                startTimer();
              },
            ),
          ),

          ///end timer
          Positioned(
            bottom: 60,
            left: 10,
            child: FloatingActionButton.extended(
              heroTag: "stop",
              label: Text('stop'),
              backgroundColor: gpsIsActive == 1 ? Colors.red : Colors.grey,
              icon: Icon(
                Icons.circle,
                size: 24.0,
                color: gpsIsActive == 1 ? Colors.red[900] : Colors.grey[600],
              ),
              onPressed: () {
                switchGps('0');
                endTimer();
              },
            ),
          ),

          ///Distace rest
          Positioned(
            bottom: 170,
            left: 10,
            child: Container(
              child: Text('to Walk: ${(distanceToWalk * 1000).ceil()} m'),
            ),
          ),

          ///Distace walked
          Positioned(
            bottom: 140,
            left: 10,
            child: Container(
              child: Text('walked: ${(distanceWalked * 1000).ceil()} m'),
            ),
          ),

          ///save
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton.extended(
              heroTag: "save",
              label: Text('Save'),
              backgroundColor: Colors.blueAccent,
              icon: Icon(
                Icons.save_alt_sharp,
                size: 24.0,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => savePopupDialog(context),
                );
              },
            ),
          ),

          ///Load
          Positioned(
            top: 20,
            left: 10,
            height: 40,
            width: 104,
            child: FloatingActionButton.extended(
              heroTag: "history",
              clipBehavior: Clip.hardEdge,
              label: Text(
                'Load',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              backgroundColor: Colors.grey[500],
              icon: Icon(
                Icons.history_outlined,
                size: 20.0,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => lastLocationPopupDialog(context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
