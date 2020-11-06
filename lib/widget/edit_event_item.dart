import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:thesis_app/page/account.dart';
import 'package:thesis_app/page/edit_event.dart';
import 'package:thesis_app/page/edit_event_info.dart';
import 'package:thesis_app/page/event_details.dart';


class EditEventItem extends StatefulWidget {
  final event;
  EditEventItem({this.event});

  @override
  _EditEventItemState createState() => _EditEventItemState();
}

String _uploadedFileURL;

class _EditEventItemState extends State<EditEventItem> {
  @override

  void initState(){
    downloadFile();
  }
  Future downloadFile() async{
    print('Download File');
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var eo = widget.event['user'];
    StorageReference ref = FirebaseStorage.instance.ref();
    ref.child('EventCoverImage/${eo}/${widget.event['eventName']}').getDownloadURL().then((fileURL) {
      setState(() {
        fileURL == null ? _uploadedFileURL = null : _uploadedFileURL = fileURL;
      });
    }).catchError((e){
      print(e.code);
    });
  }

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 30, bottom: 10,left: 20,right: 20),
      child: Material(
        child: InkWell(
          child: Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: _uploadedFileURL == null ? AssetImage('assets/cover.jpeg') : NetworkImage(_uploadedFileURL)
                    )
                ),
                width: MediaQuery.of(context).size.width * 40/100,
                height: 150,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 10,bottom: 40),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 10,bottom: 10,top: 5),
                        width: double.infinity,
                        child: Text(widget.event['eventName'] == null ? '' : widget.event['eventName'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                      ),
                      Container(
                        width: double.infinity,
                        child: FlatButton.icon(
                            onPressed: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditEventInfoPage(event: widget.event,)));
                            },
                            icon: Icon(Icons.edit), label: Text('Edit')),
                      ),
                      Container(
                        width: double.infinity,
                        child: FlatButton.icon(onPressed: (){
                            final dbRef = FirebaseDatabase.instance.reference().child("Events");

                            dbRef.once().then((DataSnapshot snapshot){
                              Map<dynamic, dynamic> values = snapshot.value;
                              values.forEach((key, value) {
                                if(value['eventName'] == widget.event['eventName']){
                                  list.remove(value);
                                  dbRef.child(key).remove().whenComplete((){
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AccountPage()));
                                    });
                                    print(key);
                                }
                              });
                            });
                          }, icon: Icon(Icons.cancel), label: Text('Cancel')),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),

    );
  }
}
