import 'package:flutter/material.dart';
import 'package:macabulos_etr/screens/confirmbooking.dart';

class BookingPage extends StatelessWidget {
  final String placeName;

  BookingPage({required this.placeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          placeName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildImageWidget(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR89e3a30I9m_JaOAhckkFlsjaR8BIOJQs3vA&s'),
                  _buildImageWidget(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpJ2bg_4T73u1PWTY_lvYDYVGljf0c7o7h-cVLSkaEHg&s'),
                  _buildImageWidget(
                      'https://cf.bstatic.com/xdata/images/hotel/max1024x768/326385709.jpg?k=793cc6a6a3f600d6d965b0ac9f96b93d61023898af032e5b7aa5426813d65253&o=&hp=1'),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Booking Details Section
            Text(
              'Welcome to $placeName',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Experience luxury and comfort in a tranquil setting.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 20),

            // Room Rates
            Text(
              'Available Rooms',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            _buildRoomOption(
              context,
              title: "Standard Room",
              price: "₱2,500 per night",
              imageUrl:
                  "https://res.cloudinary.com/simplotel/image/upload/x_0,y_66,w_1280,h_720,r_0,c_crop,q_80,fl_progressive/w_400,f_auto,c_fit/the-residency-karur/Standard_Room_2_ayx1oc",
            ),
            _buildRoomOption(
              context,
              title: "Suite",
              price: "₱3,500 per night",
              imageUrl:
                  "https://www.lottehotel.com/content/dam/lotte-hotel/lotte/yangon/accommodation/hotel/suite/royalsuite/180712-49-2000-acc-yangon-hotel.jpg.thumb.768.768.jpg",
            ),
            _buildRoomOption(
              context,
              title: "Backpacker Dormitory",
              price: "₱800 per night",
              imageUrl:
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_knVNmz0xsaO3M0U3hZgt5HdCq5R24dumDN_4KR5_lg&s",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return Container(
      margin: EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 300,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildRoomOption(BuildContext context,
      {required String title, required String price, required String imageUrl}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmBooking(
              placeName: placeName,
              roomType: title,
              roomRate: price,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Room Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            // Room Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(fontSize: 16, color: Colors.teal),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class RoomPage extends StatelessWidget {
  final String roomName;
  final String roomDescription;
  final String roomRate;
  final String imageUrl;
  final String placeName;

  RoomPage({
    required this.roomName,
    required this.roomDescription,
    required this.roomRate,
    required this.imageUrl,
    required this.placeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                imageUrl,
                width: MediaQuery.of(context).size.width,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            Text(
              roomName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Rate: $roomRate',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Text(
              roomDescription,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to confirm booking page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfirmBooking(
                        placeName: placeName,
                        roomType: roomName,
                        roomRate: roomRate,
                      ),
                    ),
                  );
                },
                child: Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
