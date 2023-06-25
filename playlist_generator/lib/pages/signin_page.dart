import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:playlist_generator/pages/playlist_generator.dart';
import 'package:playlist_generator/pages/web_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assets/colors.dart';
import 'package:http/http.dart' as http;

Future<Map<String,dynamic>> getLoginState() async {

  // final SharedPreferences prefs = await SharedPreferences.getInstance();
  // final String? id = prefs.getString('id');
  http.Response resultJSON;
  
  //if(id == null || id == 'None'){
  resultJSON =await  http.get(Uri.parse('http://192.168.0.112:5000/login'));
  //}
  //else{
    //resultJSON =await  http.get(Uri.parse('http://192.168.0.112:5000/login?id=$id'));
  //}

  return jsonDecode(resultJSON.body) as Map<String,dynamic>;
}

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key:key);

  @override
  State<SignInPage> createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInPage> {
  bool moveToMain = false;
  @override
  Widget build(BuildContext context)
  {
    if(moveToMain == true){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> PlaylistGenerator()));
    }
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration:const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/signin_background.jpg"),
              fit: BoxFit.fill,
            )
          ),
          child: Padding(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.1, 20, 0),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    "lib/assets/images/s-logo.png",
                    fit: BoxFit.fitWidth,
                    width:240, height: 240,
                    scale: 0.8
                    ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    'Welcome to Spotilist!',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30
                        )
                      ),
                  const SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: 250,
                    height: 55,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return white;
                      }
                      return spotify_light_green;
                    }),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))
                    ),
                    onPressed: () async{
                      Map<String,dynamic> returnValue = await getLoginState();
                      if( returnValue['logged_in'] == 'true') {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> PlaylistGenerator()));
                      }
                      else{
                        var urlRedirect= returnValue['redirect_uri'];
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginWeb(urlToGo: urlRedirect)));
                      }
                      },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset("lib/assets/images/spotify_logo.png", fit: BoxFit.fitWidth, width:50, height: 50, scale: 0.08),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text('Connect to Spotify', style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),

                  )
                ]
              ),
            ),
      ),
    );
  }
}