import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'chat_ui.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool hasInternet = true; // Assume internet is initially available

  @override
  void initState() {
    super.initState();
    checkInternet();
  }

  Future<void> checkInternet() async {

    // Delay for 5 seconds
    await Future.delayed(Duration(seconds: 5));

    // Navigate to the next page or perform other actions based on internet availability
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Chatpage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo here
            Lottie.asset(
              'assets/lottie/robot0.json',
              width: 190,
              height: 190,
              // Adjust width and height according to your logo size
            ),
            SizedBox(height: 30),
            // Loading animation
            CircularProgressIndicator(
              color: Colors.white38,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}