import 'dart:async';
import 'dart:io';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:playlist_generator/pages/playlist_generator.dart';
import 'package:playlist_generator/pages/signin_page.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen()
    ));
}

Future<Route> _createRoute() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? id = prefs.getString('id');

  StatefulWidget pageToReturn;
  if(id==null || id=='None'){
    pageToReturn = const SignInPage();
  }
  else{
    await  http.get(Uri.parse('http://192.168.0.112:5000/login?id=$id'));
    pageToReturn = const PlaylistGenerator();
  }
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 1500),
    pageBuilder: (context, animation, secondaryAnimation) {
      return pageToReturn;
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {

      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: (10)),
      vsync: this,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Lottie.asset(
        'lib/assets/81966-girl-listening-to-music.json',
        controller: _controller,
        frameRate: FrameRate.max,
        height: MediaQuery.of(context).size.height * 1,
        animate: true,
        onLoaded: (composition) {
          _controller
            ..duration = composition.duration
            ..forward().timeout(const Duration(milliseconds: 5000)).whenComplete(() async => Navigator.of(context).push(await _createRoute()));
        },
      ),
    );
  }
}
