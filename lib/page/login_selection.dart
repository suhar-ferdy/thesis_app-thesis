import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:thesis_app/widget/app_logo.dart';
import 'package:thesis_app/widget/email_button.dart';
import 'package:thesis_app/widget/google_button.dart';


class LoginSelectionPage extends StatefulWidget {
  @override
  _InstantLoginPageState createState() => _InstantLoginPageState();
}

class _InstantLoginPageState extends State<LoginSelectionPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLocation();
  }
  void getUserLocation () async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.redAccent,
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AppLogo(),
                GoogleButton(),
                EmailButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
