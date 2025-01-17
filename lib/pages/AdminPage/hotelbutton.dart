import 'package:flutter/material.dart';
import 'package:hoteldineflutter/pages/AdminPage/addroom.dart';
import 'package:hoteldineflutter/pages/AdminPage/viewroom.dart';


class HotelButton extends StatelessWidget {
  const HotelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(onPressed: (){
        Navigator.pop(context);
      }, icon: Icon(Icons.arrow_back)),

      title: Text('Home'),
    ),
      body: Column(

        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 73, vertical: 60),
            child: Text(
              'Select your option', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,),),
          ),

          SizedBox(width: 316,child:
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>  AddRoom()),
            );
          },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF19A7FE),
              padding: EdgeInsets.symmetric( vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
             child: Text('Add Room',style: TextStyle(fontSize: 14,color: Colors.white),),

          ),
          ),

         SizedBox(height: 25),
          SizedBox(width: 316,child:
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>  ViewRoom()),
            );
          },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF19A7FE),
              padding: EdgeInsets.symmetric( vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('View Room',style: TextStyle(fontSize: 14,color: Colors.white),),

          ),
          ),


          SizedBox(height: 25),
          SizedBox(width: 316,child:
          ElevatedButton(onPressed: (){},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF19A7FE),
              padding: EdgeInsets.symmetric( vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Update Room',style: TextStyle(fontSize: 14,color: Colors.white),),

          ),
          ),

          SizedBox(height: 25),
          SizedBox(width: 316,child:
          ElevatedButton(onPressed: (){},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF19A7FE),
              padding: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Manage Booking',style: TextStyle(fontSize: 14,color: Colors.white),),

          ),
          ),
        ],

      ),
     bottomNavigationBar:  BottomNavigationBar(
          backgroundColor: Color(0xFFE4E4E4),
          currentIndex: 1,

          items:[

            BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.apartment),label: 'Hotel'),
            BottomNavigationBarItem(icon: Icon(Icons.restaurant_rounded),label: 'Restaurant')
          ]
      ),


    );
  }
}
