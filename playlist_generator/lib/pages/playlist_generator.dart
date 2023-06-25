import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playlist_generator/pages/account_stats.dart';
import 'package:playlist_generator/pages/generated_playlist.dart';
import 'package:playlist_generator/pages/signin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assets/colors.dart';
import 'package:http/http.dart' as http;

var time ={
  0: 30,
  1: 45,
  2: 60,
  3: 90,
  4:120,
  5:150,
  6:180
};

var mood ={
  0:'Happy',
  1:'Sad',
  2:'Relaxed',
  3:'Angry',
};

Future<String> generatePlaylist(String id,String mood,int length) async{
  http.Response info = await http.get(Uri.parse('http://192.168.0.112:5000/generate?id=$id&mood=$mood&length=$length'));

  var result = jsonDecode(info.body) as Map<String,dynamic>;
  return result['playlistID'];
}

void setSignoutID() async{
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('id', 'None');
}

class PlaylistGenerator extends StatefulWidget {
  const PlaylistGenerator({Key? key}) : super(key:key);

  @override
  State<PlaylistGenerator> createState() => PlaylistGeneratorState();
}

class PlaylistGeneratorState extends State<PlaylistGenerator> {
  late Stream<Map<String,dynamic>> streamUserInfo;
  late String? id;
  bool isLoading = false;

  Stream<Map<String,dynamic>> getUserData() async*{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id');
    print(id);
    http.Response info = await http.get(Uri.parse('http://192.168.0.112:5000/get_user_info?id=$id'));

    yield jsonDecode(info.body) as Map<String,dynamic>;
  }

  @override
  void initState() {
    super.initState();
    isLoading = false;
    streamUserInfo = getUserData();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    precacheImage(const AssetImage("lib/assets/images/mood-background-texture.jpg"), context);
  }

  int playlistLength = 30;
  String moodIndex = 'Happy';
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Builder(
        builder: (context) => IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0
      ),
      drawer: Drawer(
        width: 225,
        backgroundColor: spotify_black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 25, 15, 0),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: Image.asset("lib/assets/images/logo1.png",).image,
                        fit: BoxFit.fitWidth
                        ),
                  ),
                ),
              ),
            const SizedBox(
              height: 100,
            ),
            //Generate playlist
            // FloatingActionButton(
            //   heroTag: null,
            //   onPressed: () {
            //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const PlaylistGenerator()));
            //   },
            //   elevation: 20.0,
            //   backgroundColor: spotify_dark_green,
            //   child: const Icon(Icons.audiotrack_sharp),
            // ),
            const SizedBox(
              height: 40,
            ),
            //Account stats
            FloatingActionButton(
              heroTag: null,
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> AccountStatsPage(id: id!)));
              },
              elevation: 20.0,
              backgroundColor: spotify_dark_green,
              child: const Icon(Icons.pie_chart_rounded),
            ),
            const SizedBox(
              height: 250,
            ),
            //Log Out
            FloatingActionButton(
              heroTag: null,
              onPressed: () {
                setSignoutID();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const SignInPage()));
              },
              elevation: 20.0,
              backgroundColor: spotify_dark_green,
              child: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: streamUserInfo,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
            Timer(const Duration(seconds: 1), () {});
            Map<String,dynamic>? data = snapshot.data;
            return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("lib/assets/images/mood-background-texture.jpg"),
                      fit: BoxFit.fill,
                    )
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(snapshot.data!['imageUrl']),
                                  fit: BoxFit.cover
                                  ),
                              border: Border.all(
                              color: spotify_dark_green,
                              width: 4,
                            ),
                            ),
                          ),
                        ),
                        const SizedBox(
                        height: 15,
                        ),
                        RichText(
                          text: const TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(Icons.favorite, size: 25, color: spotify_dark_green,),
                              ),
                              TextSpan(
                                text: " Liked songs: ",
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)
                              )
                            ]
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                          ),
                          RichText(
                          text: TextSpan(
                              text: " ${data!['likedCounter']} ",
                              style: const TextStyle(color: spotify_dark_green, fontSize: 20, fontWeight: FontWeight.w600)
                          )
                        ),
                        const SizedBox(
                          height: 15,
                          ),
                        RichText(
                          text: const TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(Icons.audiotrack_sharp, size: 25, color: spotify_dark_green,),
                              ),
                              TextSpan(
                                text: " Playlists generated: ",
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)
                              )
                            ]
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                          ),
                          RichText(
                          text: TextSpan(
                              text: " ${data['playlistsCreated']['total']} ",
                              style: const TextStyle(color: spotify_dark_green, fontSize: 20, fontWeight: FontWeight.w600)
                          )
                        ),
                        const SizedBox(
                          height: 60,
                          ),
                          RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Pick your mood:",
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)
                              )
                            ]
                          )
                        ),
                        const SizedBox(
                          height: 8,
                          ),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 75),
                          borderRadius: BorderRadius.circular(25),
                          minSize: 50,
                          color: spotify_dark_green,
                          onPressed: () => showCupertinoModalPopup(
                            context: context,
                            builder: (_) => SizedBox(
                              width: double.infinity,
                              height: 250,
                              child: CupertinoPicker(
                              backgroundColor: Colors.white,
                              itemExtent: 30,
                              scrollController: FixedExtentScrollController(
                                initialItem: 0
                              ),
                              children: const[
                                Text('Happy'),
                                Text('Sad'),
                                Text('Relaxed'),
                                Text('Angry')
                              ],
                              onSelectedItemChanged: (int value) {
                                setState(() {
                                  moodIndex = mood[value]!;
                                });
                              },
                              )
                            ),
                          ),
                          child:Container(constraints: const BoxConstraints(maxWidth: 100,minWidth: 100),
                            alignment: Alignment.center,
                            child:Text(moodIndex, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24))),
                        ),
                        const SizedBox(
                          height: 50,
                          ),
                          RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Choose playlist length:",
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)
                              )
                            ]
                          )
                        ),
                        const SizedBox(
                          height: 5,
                          ),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 75),
                          borderRadius: BorderRadius.circular(25),
                          minSize: 50,
                          color: spotify_dark_green,
                          onPressed: () => showCupertinoModalPopup(
                            context: context,
                            builder: (_) => SizedBox(
                              width: double.infinity,
                              height: 250,
                              child: CupertinoPicker(
                              backgroundColor: Colors.white,
                              itemExtent: 30,
                              scrollController: FixedExtentScrollController(
                                initialItem: 0
                              ),
                              children: const[
                                Text('30'),
                                Text('45'),
                                Text('60'),
                                Text('90'),
                                Text('120'),
                                Text('150'),
                                Text('180')
                              ],
                              onSelectedItemChanged: (int value) {
                                setState(() {
                                  playlistLength = time[value]!;
                                });
                              },
                              )
                            ),
                          ),
                          child: Container(constraints: const BoxConstraints(maxWidth: 100,minWidth: 100),
                            alignment: Alignment.center,
                            child:Text('$playlistLength min.', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24))
                          )
                        ),
                        const SizedBox(
                          height: 60,
                          ),
                        isLoading == false ? DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.white24,
                              Colors.white24,
                            ]
                            ),
                            borderRadius: BorderRadius.circular(50),
                          
                          ),
                        child:  ElevatedButton(
                            onPressed: ()async{
                              setState(() {
                                isLoading = true;
                              });
                              var playlistID = await generatePlaylist(id!,moodIndex,playlistLength);
                              setState(() {
                                streamUserInfo=getUserData();           
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> PlaylistPage(id: id!,playlistID: playlistID,mood: moodIndex,length: playlistLength,)));         
                                }
                              );
                            },
                            style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledForegroundColor: Colors.transparent.withOpacity(0.38), disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
                            shadowColor: Colors.transparent,
                          ),
                          child: const Text('Generate playlist', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24))
                         ) 
                        ) : 
                          Container(
                          color: Colors.transparent, 
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            color: spotify_dark_green,
                            backgroundColor: Colors.black
                          )
                        ),
                      ],
                    ),
                  ),
              );
            }else{
              return Container(
                color: Colors.black, 
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: spotify_dark_green,
                  backgroundColor: Colors.black
                  )
                );
            }
          },
        )
    );
  }
}