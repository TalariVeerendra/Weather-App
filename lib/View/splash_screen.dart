import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weatherpredication/Utilis/colors.dart';
import 'package:weatherpredication/View/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WeatherAppHomeScreen()),
        );
      });
    });

  }

  @override
  void dispose() {

    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Padding
          (padding: EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Center
                (child: Text(
                "Weather in your city",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.2,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                ),
              ),
              Spacer(),
              Image.asset('assets/images/cloudy.png',height: 350,),

              Spacer(),
              Center
                (child: Text(
                "Get know you weather app radar recipitations forcast",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )
                  ),
                    onPressed: (){
                    _timer?.cancel();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder:
                          (context)=> WeatherAppHomeScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 15),
                      child: Text("Get started",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
