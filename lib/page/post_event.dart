import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_search_flutter/mapbox_search_flutter.dart';
import 'package:thesis_app/firebase/crud.dart';
import 'package:thesis_app/page/edit_event_info.dart';


class PostEventPage extends StatefulWidget {
  LatLng latLng;
  Set<Marker> marker;
  PostEventPage({this.latLng,this.marker});
  _PostEventPageState createState() => _PostEventPageState();
}

var _dates = '';
var _times = '';
var _placeData;
var lat;
var lng;
int _day;
int _month;
int _year;
int _hour;
int _minute;
String _valCategory;
List _myCategories = [
  "#Tech",
  "#Sport",
  "#Culinary",
  "#Seminar",
  "#Art",
  "#Music",
  "#Education",
  "#E-Sport"
];
final picker = ImagePicker();
File _image;
StorageReference ref = FirebaseStorage.instance.ref();
final f = new DateFormat('yyyy-MM-dd');
TextEditingController eventNameController = new TextEditingController();
TextEditingController descController = new TextEditingController();
TextEditingController pathController = new TextEditingController();
String _uploadedFileURL;
Position position;

class _PostEventPageState extends State<PostEventPage>  {
  @override

  void initState() {
    print(widget.latLng);
    // TODO: implement initState
    super.initState();
  }


  void showDatePicker(){
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(2018, 3, 5),
        onConfirm: (date) {
          setState(() {
            _day = date.day;
            _month = date.month;
            _year = date.year;
            _dates = f.format(date).toString();
          });

        },
        currentTime: DateTime.now(), locale: LocaleType.id);
  }
  void showTimePicker(){
    DatePicker.showTimePicker(context,
        showTitleActions: true,
        onConfirm: (time) {
          setState(() {
            _hour = time.hour;
            _minute = time.minute;
            _times = '$_hour : $_minute';
          });

        },
        currentTime: DateTime.now(), locale: LocaleType.id);
  }

  void registerEvent() async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var uid = user.uid;
    var data = {
      "user" : uid,
      "eventName" : eventNameController.text,
      "coverImageUrl" : _uploadedFileURL,
      "description" : descController.text,
      "address" : _placeData.toString(),
      "lat" : lat,
      "lng" : lng,
      "dates" : _dates,
      "times" : _times,
      "year" : _year,
      "month" : _month,
      "day" : _day,
      "hour" : _hour,
      "minute" : _minute,
      "category" : _valCategory
    };
    CRUD().readDuplicateAndCreate(data,'Events','eventName');
  }
  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed:  (){
        uploadFile();
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirmation"),
      content: Text("Are you sure want to register your event? Once the event registered you will not able to change it."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showImgPickerDialog(BuildContext context){
    AlertDialog alert = AlertDialog(
      title: Text("Image Picker"),
      content: Wrap(
        direction: Axis.vertical,
        children: [
          FlatButton.icon(onPressed: (){
              getImage('camera');
              Navigator.of(context, rootNavigator: true).pop();
            }, icon: Icon(Icons.camera_enhance), label: Text('Camera'),),
          FlatButton.icon(onPressed: (){
              getImage('gallery');
              Navigator.of(context, rootNavigator: true).pop();
            }, icon: Icon(Icons.photo), label: Text('Gallery')),
        ],
      ),

    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future getImage(String opt) async {
    var pickedFile;
    if(opt == 'camera'){
      pickedFile = await picker.getImage(source: ImageSource.camera);
    }else if(opt == 'gallery'){
      pickedFile = await picker.getImage(source: ImageSource.gallery);
    }
    setState(() {
      _image = File(pickedFile.path);
      pathController.text = _image.toString();

    });
  }

  Future uploadFile() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var uid = user.uid;
    var eventName = eventNameController.text;
    StorageUploadTask uploadTask = ref.child('EventCoverImage/$uid').child(eventName).putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    downloadFile();
  }

  Future downloadFile() async{
    print('Download File');
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var uid = user.uid;
    var eventName = eventNameController.text;
    StorageReference ref = FirebaseStorage.instance.ref();
    ref.child('EventCoverImage/$uid').child(eventName).getDownloadURL().then((fileURL) {
      setState(() {
        fileURL == null ? _uploadedFileURL = null : _uploadedFileURL = fileURL;
      });
    }).catchError((e){
      print(e.code);
    }).whenComplete(() {
      try{
        registerEvent();
      }catch(e){
        print(e);
      }
    });
  }

  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home : SafeArea(
        child: Scaffold(
            body: Column(
              children: [
                Expanded(
                  flex: 8,
                  child: ListView(
                      children : [
                        Container(
                          margin: EdgeInsets.only(left: 10,right: 10,top: 20),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: TextField(
                                    readOnly: true,
                                    controller: pathController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Cover image',
                                    ),
                                  )
                              ),
                              Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: RaisedButton(
                                        onPressed: (){
                                          showImgPickerDialog(context);
                                        },
                                        child: Text('browse')
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10,right: 10,top: 20),
                          child : TextField(
                            controller: eventNameController,
                            decoration : InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Event name',
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10,right: 10,top: 20),
                          child : TextField(
                            controller: descController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration : InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Event description',
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10,right: 10,top: 20),
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(3 )),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              isExpanded: true,
                              hint: Text("Select Category"),
                              value: _valCategory,
                              items: _myCategories.map((value) {
                                return DropdownMenuItem(
                                  child: Text(value),
                                  value: value,
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _valCategory = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5,right: 5,top: 20,bottom: 10),
                          child: MapBoxPlaceSearchWidget(
                            apiKey: "pk.eyJ1Ijoic3VoYWZlcmR5IiwiYSI6ImNrYzc2NXo3dzBlYmkydWsxYTB5ejZyMnoifQ.iAYJVKIDBZYLdlNtiflXeQ",
                            limit: 10,
                            country: "id",
                            searchHint: 'Pick location',
                            onSelected: (place) {
                              setState(() {
                                widget.marker.clear();
                                _placeData = place;
                                lat = place.center[1];
                                lng = place.center[0];
                                widget.latLng = LatLng(lat,lng);
                                widget.marker.add(
                                  Marker(
                                    markerId:
                                    MarkerId(widget.latLng.toString()),
                                    icon: BitmapDescriptor.defaultMarker,
                                    position: widget.latLng,
                                  ),
                                );
                              });
                            },
                            context: context,
                          ),
                        ),
//                        Container(
//                          height: 300,
//                          child: GoogleMap(
//                            mapType: MapType.normal,
//                            initialCameraPosition: CameraPosition(
//                              target: widget.latLng,
//                              zoom: 15.0,
//                            ),
//                            markers: widget.marker,
//                            onTap: (position){
//                              setState(() {
//                                widget.marker.clear();
//                                lat = position.latitude;
//                                lng = position.longitude;
//                                widget.marker.add(
//                                  Marker(
//                                    markerId:
//                                    MarkerId("${widget.latLng.latitude}, ${widget.latLng.longitude}"),
//                                    icon: BitmapDescriptor.defaultMarker,
//                                    position: LatLng(position.latitude,position.longitude),
//                                  ),
//                                );
//                              });
//                            },
//                          ),
//                        ),
                        FlatButton(
                            onPressed: () {
                              showDatePicker();
                            },
                            child: Text(
                              'Pick date',
                              style: TextStyle(color: Colors.blue, fontSize: 18),
                            )),
                        Center(child: Text('$_dates')),
                        FlatButton(
                            onPressed: () {
                              showTimePicker();
                            },
                            child: Text(
                              'Pick time',
                              style: TextStyle(color: Colors.blue,fontSize: 18),
                            )),
                        Center(child: Text('$_times')),

                      ]
                  ),),
                Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.only(left: 30, right: 30, bottom: 30, top: 30),
                      child: Container(
                        width: double.infinity,
                        child: RaisedButton(
                          padding: EdgeInsets.only(left: 30,right: 30,top: 20, bottom: 20),
                          onPressed: (){
                            showAlertDialog(context);
                          },
                          color: Colors.redAccent,
                          child: Text('Post my event..', style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ))

              ],
            )
        ),
      ),

    );

  }
}