import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookedRooms extends StatefulWidget {
  @override
  _BookedRoomsState createState() => _BookedRoomsState();
}

class _BookedRoomsState extends State<BookedRooms> {
  late Stream<List<Map<String, dynamic>>> bookedRoomsStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to listen for changes in the "bookings" collection
    bookedRoomsStream = FirebaseFirestore.instance
        .collection('bookings')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final roomType = doc['roomType'] as String;
              final checkIn = (doc['checkIn'] as Timestamp).toDate();
              final checkOut = (doc['checkOut'] as Timestamp).toDate();
              return {
                'roomType': roomType,
                'checkIn': checkIn,
                'checkOut': checkOut,
              };
            }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Booked Rooms',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal, // Changed to teal for a fresh look
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>( 
        stream: bookedRoomsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'You have not booked any rooms yet.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.teal, // Added teal color for consistency
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final booking = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4, // Added shadow for a card-like effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      booking['roomType'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal, // Styled with teal color
                      ),
                    ),
                    subtitle: Text(
                      'Check-in: ${DateFormat('yyyy-MM-dd').format(booking['checkIn'])}\n'
                      'Check-out: ${DateFormat('yyyy-MM-dd').format(booking['checkOut'])}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
