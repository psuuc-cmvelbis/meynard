import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:macabulos_etr/services/stripe_service.dart';

class ConfirmBooking extends StatefulWidget {
  final String placeName;
  final String roomType;
  final String roomRate;

  ConfirmBooking({
    required this.placeName,
    required this.roomType,
    required this.roomRate,
  });

  @override
  _ConfirmBookingState createState() => _ConfirmBookingState();
}

class _ConfirmBookingState extends State<ConfirmBooking> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late DateTime _selectedCheckInDate;
  late DateTime _selectedCheckOutDate;
  late int _finalRoomRate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _selectedCheckInDate = DateTime.now();
    _selectedCheckOutDate = DateTime.now().add(Duration(days: 1));
    _finalRoomRate = _calculateRoomRate(widget.roomType);
  }

  int _calculateRoomRate(String roomType) {
    switch (roomType) {
      case "Suite":
        return 3500;
      case "Standard Room":
        return 2500;
      case "Backpacker Dormitory":
        return 800;
      default:
        return 0;
    }
  }

  int _calculateTotalCost() {
    final days = _selectedCheckOutDate.difference(_selectedCheckInDate).inDays;
    int totalDays = (days == 0) ? 1 : days; // Minimum of 1 day
    return totalDays * _finalRoomRate;
  }

  Future<void> _submitBooking() async {
    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'placeName': widget.placeName,
        'name': _nameController.text,
        'email': _emailController.text,
        'checkIn': _selectedCheckInDate,
        'checkOut': _selectedCheckOutDate,
        'roomType': widget.roomType,
        'totalCost': _calculateTotalCost(),
        'createdAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking Confirmed!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to confirm booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmBookingWithPayment() async {
    int totalCost = _calculateTotalCost();
    bool paymentSuccess = await StripeService.instance.makePayment(
      amount: totalCost,
      currency: "usd",
    );

    if (paymentSuccess) {
      await _submitBooking();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectCheckInDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedCheckInDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedCheckInDate = pickedDate;
        if (_selectedCheckOutDate.isBefore(_selectedCheckInDate)) {
          _selectedCheckOutDate = _selectedCheckInDate.add(Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedCheckOutDate,
      firstDate: _selectedCheckInDate.add(Duration(days: 1)),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedCheckOutDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalCost = _calculateTotalCost();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Confirm Booking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.placeName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Room Type: ${widget.roomType}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Divider(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildDateTile(
                    title: 'Check-in Date',
                    date: _selectedCheckInDate,
                    onTap: () => _selectCheckInDate(context),
                  ),
                  SizedBox(height: 12),
                  _buildDateTile(
                    title: 'Check-out Date',
                    date: _selectedCheckOutDate,
                    onTap: () => _selectCheckOutDate(context),
                  ),
                  Divider(height: 32),
                  Text(
                    'Total Cost: ₱${totalCost.toString()}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmBookingWithPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirm Booking & Pay',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTile(
      {required String title,
      required DateTime date,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        DateFormat('yyyy-MM-dd').format(date),
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
      trailing: Icon(Icons.calendar_today, color: Colors.teal),
      onTap: onTap,
    );
  }
}
