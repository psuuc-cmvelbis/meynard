import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:macabulos_etr/screens/bookedrooms.dart';
import 'package:macabulos_etr/screens/bookingpage.dart';

class LandingScreens extends StatefulWidget {
  LandingScreens({Key? key}) : super(key: key);

  @override
  State<LandingScreens> createState() => _LandingScreensState();
}

class _LandingScreensState extends State<LandingScreens> {
  static final initialPosition = LatLng(15.9758, 120.5707);
  late GoogleMapController mapController;

  late TextEditingController nameController;
  late TextEditingController detailsController;
  late TextEditingController imageUrlController;

  Set<Marker> markers = {};
  BitmapDescriptor? customIcon;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    detailsController = TextEditingController();
    imageUrlController = TextEditingController();
    loadCustomIcon();
    getCurrentLocations();
    loadMarks();
  }

  @override
  void dispose() {
    nameController.dispose();
    detailsController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  // Load the custom icon
  Future<void> loadCustomIcon() async {
    final ImageConfiguration imageConfiguration =
        ImageConfiguration(size: Size(24, 24));
    customIcon = await BitmapDescriptor.fromAssetImage(
      imageConfiguration,
      'assets/hotelicon.png',
    );
  }

  void getCurrentLocations() async {
    if (!await checkServicePermission()) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15,
    )));
  }

  Future<bool> checkServicePermission() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location Service is disabled")));
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Location permission is denied. Please accept the permission to use map.'),
          ),
        );
      }
      return false;
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Location permission is permanently denied. Please change it in settings to continue.'),
        ),
      );
      return false;
    }
    return true;
  }

  // Load Markers from Firebase
  Future<void> loadMarks() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('favePlace').get();

      markers.clear();

      querySnapshot.docs.forEach((doc) {
        dynamic position = doc['position'];

        if (position is GeoPoint) {
          LatLng markerPosition = LatLng(position.latitude, position.longitude);

          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: markerPosition,
              icon: customIcon ?? BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                title: doc['PlaceName'] ?? 'Unknown Place',
                snippet: doc['Details'] ?? '',
              ),
              onTap: () {
                showPlaceInfo(doc);
              },
            ),
          );
        } else {
          print('Invalid position data in Firestore document: $position');
        }
      });

      setState(() {});
    } catch (e) {
      print('Error loading markers: $e');
    }
  }

  // Show place info in a bottom sheet with enhanced UI
  void showPlaceInfo(QueryDocumentSnapshot doc) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc['PlaceName'] ?? 'Unknown Place',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 8),
              Text(
                doc['Details'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              if (doc['imageUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    doc['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              SizedBox(height: 8),
              Center(
                  child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingPage(placeName: doc['PlaceName']),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.teal, // Corrected button color property
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Visit',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )), 
            ],
          ),
        );
      },
    );
  }

  // Function to navigate to the booked rooms screen
  void navigateToBookedRooms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookedRooms(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.location_pin,
          size: 40,
          color: Colors.white,
        ),
        title: Text(
          'CozyHub',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: navigateToBookedRooms,
            icon: Icon(Icons.bookmark),
            color: Colors.white,
          )
        ],
      ),
      body: Container(
        color: Colors.blue[50],
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                mapController = controller;
              },
              markers: markers,
            ),
          ),
        ),
      ),
    );
  }
}
