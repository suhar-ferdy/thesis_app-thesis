import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thesis_app/widget//event_item.dart';
import 'package:thesis_app/widget/botnavbar.dart';
import 'package:thesis_app/widget/edit_event_item.dart';

class EditEventPage extends StatefulWidget {
  EditEventPage({Key key}) : super(key: key);
  @override
  _EditEventPageState createState() => _EditEventPageState();
}


final dbRef = FirebaseDatabase.instance.reference().child("Events");
List list=new List();
FirebaseUser user;
class _EditEventPageState extends State<EditEventPage> {
  // ignore: must_call_super
  void initState(){
    loadData();
  }
  void loadData()async{
    user = await FirebaseAuth.instance.currentUser();
    loadEvents();
  }
  void loadEvents(){
    var uid = user.uid;
    dbRef.once().then((DataSnapshot snapshot){
      list.clear();
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key,value) {
        if(value['user']== uid){
          setState(() {
            list.add(value);
          });
        }
      });
    }).whenComplete((){
      if(list.isEmpty){
        Fluttertoast.showToast(
            msg: "No Events",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: Scaffold(
              body: Stack(
                children: <Widget>[
                  Container(
                      child: Column(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                child: Text('Your Events',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                                margin: EdgeInsets.only(left: 20,right: 20,top: 35),
                              ),
                              Container(
                                width: double.infinity,
                                child: Text('Update your events here',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                margin: EdgeInsets.only(left: 20,right: 20,top: 10),
                              ),
                            ],
                          ),
                          Expanded(
                            flex: 8,
                            child: Container(
                              child: ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (BuildContext ctx, int index){
                                  return EditEventItem(event: list[index],);
                                },
                              ),
                            ),
                          )
                        ],
                      )
                  ),
                ],
              ),
          ),
        )
    );
  }
}

