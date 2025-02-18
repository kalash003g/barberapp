import 'package:flutter/material.dart';
import '../services/mongodb_service.dart';
import '../services/auth_service.dart';

// ignore: must_be_immutable
class Booking  extends StatefulWidget{
String service;
Booking({super.key, required this.service});

  @override
  State<Booking> createState()=> _BookingState();
  }

  class _BookingState extends State<Booking>{
    
  DateTime? selectedDate;
  TimeOfDay _selectedTime=TimeOfDay.now();
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async{
    final TimeOfDay? picked=await showTimePicker(context: context, initialTime: _selectedTime);
    if(picked!=null && picked!=_selectedTime){
      setState(() {
        _selectedTime=picked;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleBooking() async {
    if (selectedDate == null) {
      _showMessage('Please select a date');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userEmail = await AuthService.getUserEmail();
      if (userEmail == null) {
        _showMessage('Please login to book an appointment');
        return;
      }

      final success = await MongoDBService.addBooking(
        userEmail,
        widget.service,
        selectedDate!,
        _selectedTime,
      );

      if (success) {
        _showMessage('Booking successful!');
        Navigator.pop(context);
      } else {
        _showMessage('Failed to book appointment. Please try again.');
      }
    } catch (e) {
      _showMessage('An error occurred. Please try again.');
      print('Error booking appointment: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFF2b1615),
      body: Container(
        margin: EdgeInsets.only(left: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 50.0),
            child:Icon(Icons.arrow_back_ios_new_rounded,color: Colors.white,size: 30.0,)
                
        ),),
        SizedBox(height: 20.0,),
        Text("Let's the\njourney begin",style:TextStyle(color: Colors.white70, fontSize: 28.0, fontWeight: FontWeight.w500)),
        SizedBox(height: 20.0,),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Image.asset("images/discount.png", fit: BoxFit.cover,)),
            SizedBox(height: 20.0,),
          Text(widget.service,style:TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold)),
          SizedBox(height: 20.0,),
          Container(
            padding: EdgeInsets.only(top: 10.0,bottom: 10.0,),
            decoration: BoxDecoration(
              color: Color(0xFFb4817e),borderRadius: BorderRadius.circular(20)),
            width: MediaQuery.of(context).size.width,
            child: Column(children: [
              Text("Set a Date",style:TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w500)),
              SizedBox(height: 10.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 IconButton(
                  icon: const Icon(Icons.calendar_month_outlined),
                  color: Colors.white,
                  onPressed: () => _selectDate(context),
                ),
                  SizedBox(width: 20.0,),
                  Text(
                  selectedDate == null
                      ? "Select a Date"
                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",style:TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold)),
                ],
              ),
            ],),
          ),

          SizedBox(height: 20.0,),
          Container(
            padding: EdgeInsets.only(top: 10.0,bottom: 10.0,),
            decoration: BoxDecoration(
              color: Color(0xFFb4817e),borderRadius: BorderRadius.circular(20)),
            width: MediaQuery.of(context).size.width,
            child: Column(children: [
              Text("Set a Time",style:TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w500)),
              SizedBox(height: 10.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(onTap: (){ 
                    _selectTime(context);
                  },child: Icon(
                      Icons.alarm,
                      color: Colors.white,
                      size: 30.0,
                      ),
                      ),
                  SizedBox(width: 20.0,),
                  Text(_selectedTime.format(context),style:TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold)),
                ],
              ),
            ],),
          ),
        SizedBox(height: 30.0,),
        GestureDetector(
          onTap: _isLoading ? null : _handleBooking,
        
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          decoration: BoxDecoration(
            color: _isLoading ? Colors.grey : Color(0xFFfe8f33), 
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Center(
            child: _isLoading 
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  "Book Now",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0, 
                    fontWeight: FontWeight.bold
                  ),
                ),
          ),
        ),
    ),
          

        ],),),);
}
}