import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thesis_app/widget//event_item.dart';
import 'package:thesis_app/widget/botnavbar.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}


final dbRef = FirebaseDatabase.instance.reference().child("Events");
List list=new List();
class _HomePageState extends State<HomePage> {
  // ignore: must_call_super
  void initState(){
    loadEvents();

  }

  void loadEvents(){
    dbRef.once().then((DataSnapshot snapshot){
      list.clear();
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key,values) {
        if(!timeDifference(values['day'], values['month'], values['year'], values['hour'], values['minute']).isNegative){
          setState(() {
            list.add(values);
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
  void lodEventsThisWeek(){
    var now = DateTime.now();
    while(now.weekday != 7){
        now = now.add(new Duration(days: 1));
    }
    dbRef.once().then((DataSnapshot snapshot){
      setState(() {
        list.clear();
      });
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key,values) {
        if(!timeDifference(values['day'], values['month'], values['year'], values['hour'], values['minute']).isNegative){
          var dateEvent = DateTime(now.year,now.month,now.day,now.hour,now.minute);
          var date = DateTime(values['year'],values['month'],values['day'],values['hour'],values['minute']);
          var val  = dateEvent.difference(date);
          if(!val.isNegative){
            setState(() {
              list.add(values);
            });
          }
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
  void loadEventsToday(){
    dbRef.once().then((DataSnapshot snapshot){
      setState(() {
        list.clear();
      });
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key,values) {
        if(!timeDifference(values['day'], values['month'], values['year'], values['hour'], values['minute']).isNegative){
          var date = DateTime(values['year'],values['month'],values['day'],values['hour'],values['minute']);
          var now = DateTime.now();
          if(date.year == now.year && date.month == now.month && date.day == now.day && date.hour >= now.hour  && date.minute >= now.minute){
            setState(() {
              list.add(values);
            });
          }
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
  void loadEventsThisMonth(){
    DateTime now = new DateTime.now();
    DateTime lastDayOfMonth = new DateTime(now.year, now.month + 1, 0);
    print("${lastDayOfMonth.month}/${lastDayOfMonth.day}");
    dbRef.once().then((DataSnapshot snapshot){
      list.clear();
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key,values) {
        if(!timeDifference(values['day'], values['month'], values['year'], values['hour'], values['minute']).isNegative){
          if(lastDayOfMonth.month == now.month && lastDayOfMonth.day >= now.day){
            setState(() {
              list.add(values);
            });
          }
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
  Duration timeDifference(int day, int month, int year, int hour, int minute){
    var dateEvent = DateTime(year,month,day,hour,minute);
    var date = DateTime.now();
    var val  = dateEvent.difference(date);
    return val;
  }
  String dropdownValue = 'All';

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
                                child: Text('What\'s good in?',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                                margin: EdgeInsets.only(left: 20,right: 20,top: 35),
                              ),
                              Container(
                                width: double.infinity,
                                child: Text('Indonesia',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                margin: EdgeInsets.only(left: 20,right: 20,top: 10),
                              ),
                              DropdownButton<String>(
                                value: dropdownValue,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Colors.deepPurple),
                                underline: Container(
                                  height: 2,
                                  color: Colors.deepPurpleAccent,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    dropdownValue = newValue;
                                    if(newValue == 'All'){
                                      loadEvents();
                                    }else if(newValue == 'Today'){
                                      loadEventsToday();
                                    }else if(newValue == 'This Week'){
                                      lodEventsThisWeek();
                                    }else if(newValue == 'This Month'){
                                      loadEventsThisMonth();
                                    }
                                  });
                                },
                                items: <String>['All','Today', 'This Week', 'This Month' ]
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                          Expanded(
                            flex: 8,
                            child: Container(
                              child: ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (BuildContext ctx, int index){
                                  return EventItem(event: list[index],);
                                },
                              ),
                            ),
                          )
                        ],
                      )
                  ),
                ],
              ),
              bottomNavigationBar: BotNavBar(currIndex: 0,)
          ),
        )
    );
  }
}

