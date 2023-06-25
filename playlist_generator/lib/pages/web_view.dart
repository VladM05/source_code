import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:playlist_generator/pages/playlist_generator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../assets/colors.dart';

class LoginWeb extends StatefulWidget {
  final urlToGo;
  const LoginWeb({Key? key,required this.urlToGo}) : super(key: key);
  @override
  State<LoginWeb> createState() => _LoginWeb();
}

Future<Map<String, dynamic>> saveInformation(Uri url) async{
  final resultJSON =await  http.get(Uri.parse(url.toString()));

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  Map<String,dynamic> decoded= jsonDecode(resultJSON.body) as Map<String,dynamic>;
  await prefs.setString('id', decoded['id']);

  return decoded;
}

class _LoginWeb extends State<LoginWeb> {
  double _progress = 0;
  var info;
  late InAppWebViewController  inAppWebViewController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: Uri.parse(widget.urlToGo)
                ),
                onWebViewCreated: (InAppWebViewController controller){
                  inAppWebViewController = controller;
                },
                onProgressChanged: (InAppWebViewController controller , int progress){
                  setState(() {
                    _progress = progress / 100;
                  });
                },
                onLoadStart: (InAppWebViewController inAppWebViewController, Uri? uri) async {
                  var url='${uri!.scheme}://${uri.host}:5000${uri.path}';
                  print(url);
                  if(url.toString() == 'http://192.168.0.112:5000/redirect'){
                    await saveInformation(uri).then((value) => Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistGenerator())));
                  }
                },
                onLoadStop: (InAppWebViewController inAppWebViewController, Uri? uri){
                  var url='${uri!.scheme}://${uri.host}:5000${uri.path}';
                  if(url.toString() == 'http://192.168.0.112:5000/redirect'){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return Container(
                        color: Colors.black, 
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          color: spotify_dark_green,
                          backgroundColor: Colors.black
                          )
                        );
                      })
                    );
                  }
                },
              ),
              _progress < 1 ? Container(
                child: LinearProgressIndicator(
                  value: _progress,
            ),
          )
          :const SizedBox()
        ],
      ),
    );
  }
}