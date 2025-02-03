import 'package:flutter/material.dart';
import 'package:hoteldineflutter/pages/AdminPage/resadditem.dart';
import 'package:hoteldineflutter/pages/AdminPage/resviewitem.dart';
import 'package:hoteldineflutter/pages/AdminPage/hotelbutton.dart';
import 'package:hoteldineflutter/pages/AdminPage/adminpage.dart';

import 'manageorder.dart';

class RestaurantButton extends StatelessWidget {
  const RestaurantButton({super.key});

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
              'Admin Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,),),
          ),

          SizedBox(width: 316,child:
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>  AddItem()),);

          },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF19A7FE),
              padding: EdgeInsets.symmetric( vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Add Item',style: TextStyle(fontSize: 14,color: Colors.white),),

          ),
          ),

          SizedBox(height: 25),
          SizedBox(width: 316,child:
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>  ViewItem()),);

          },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF19A7FE),
              padding: EdgeInsets.symmetric( vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('View Item',style: TextStyle(fontSize: 14,color: Colors.white),),

          ),
          ),




          SizedBox(height: 25),
          SizedBox(width: 316,child:
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) =>ManageOrder(),));
          },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF19A7FE),
              padding: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Manage Order',style: TextStyle(fontSize: 14,color: Colors.white),),

          ),
          ),
        ],

      ),



    );
  }
}
