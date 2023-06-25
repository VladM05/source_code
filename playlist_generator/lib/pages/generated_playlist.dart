import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:playlist_generator/assets/colors.dart';
import 'package:playlist_generator/pages/account_stats.dart';
import 'package:playlist_generator/pages/playlist_generator.dart';
import 'package:playlist_generator/pages/signin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

void setSignoutID() async{
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('id', 'None');
}

Future<String> generatePlaylist(String id,String mood,int length, String oldPlaylistID) async{
  http.Response info = await http.get(Uri.parse('http://192.168.0.112:5000/generate?id=$id&mood=$mood&length=$length&oldID=$oldPlaylistID'));

  var result = jsonDecode(info.body) as Map<String,dynamic>;
  return result['playlistID'];
}

class PlaylistPage extends StatefulWidget {
  final String mood;
  final int length;
  final String id;
  String playlistID;
  PlaylistPage({Key? key,required this.id,required this.playlistID,required this.mood,required this.length}) : super(key:key);

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage>{
  bool isLoading = false;
  var audioPlayer = AudioPlayer();
  late int indexSongPlaying;
  late Stream<Map<String,dynamic>> playlistInfo;

  Stream<Map<String,dynamic>> getPlaylistData() async*{

    http.Response info = await http.get(Uri.parse('http://192.168.0.112:5000/get_playlist_info?id=${widget.id}&playlistID=${widget.playlistID}'));

    print(jsonDecode(info.body));
    yield jsonDecode(info.body) as Map<String,dynamic>;
  }

  Icon getIcon(int index){
    if(indexSongPlaying == index){
      if(audioPlayer.state == PlayerState.paused){
        return const Icon(
          Icons.pause,
          size: 40,
          color: spotify_dark_green,
        );
      }
      if(audioPlayer.state == PlayerState.playing){
        return const Icon(
          Icons.play_arrow,
          size: 40,
          color: spotify_dark_green,
        );
      }
    }
    return const Icon(
      Icons.play_arrow,
      size: 40,
      color: Colors.white70,
    );
  }

  @override
  void initState() {
    playlistInfo = getPlaylistData();
    indexSongPlaying = -1;
    super.initState();
  }

  @override
    Widget build(BuildContext context) {
      if(isLoading == true){
        return Container(
          color: Colors.black, 
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            color: spotify_dark_green,
            backgroundColor: Colors.black
          )
        );
      }
      return  Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
        leading: Builder(
        builder: (context) => IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      drawer: Drawer(
        width: 200,
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
            ///Generate playlist
            FloatingActionButton(
              heroTag: null,
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const PlaylistGenerator()));
              },
              elevation: 20.0,
              backgroundColor: spotify_dark_green,
              child: const Icon(Icons.audiotrack_sharp),
            ),
            const SizedBox(
              height: 40,
            ),
            //Account stats
            FloatingActionButton(
              heroTag: null,
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> AccountStatsPage(id: widget.id)));
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
        body: SingleChildScrollView(
          child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/assets/images/mood-background-texture.jpg"),
                fit: BoxFit.fill,
              )
            ),
            child: StreamBuilder(
              stream: playlistInfo,
              builder: (context, snapshot){
                print(snapshot.connectionState);
                print(snapshot.hasData);
                if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                  var data = snapshot.data;
                  var total_duration_object = Duration(milliseconds: data!['total_duration']);
                  var total_duration = '';
                  if(total_duration_object.inHours == 0){
                    total_duration = total_duration_object.toString().substring(2,7);
                  }
                  else{
                    total_duration = total_duration_object.toString().substring(0,7);
                  }
                  return ListView(
                    scrollDirection: Axis.vertical,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      Container(
                      margin: const EdgeInsets.only(right: 10, left: 10),
                      padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            data['images'][1]['url'],
                            fit: BoxFit.cover,
                            height: 140,
                            width: 140,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                  data['name'],
                                  style: const TextStyle(color:  Colors.white, fontSize: 18, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                Text(
                                  'Total Tracks: ${data['tracks']['total'].toString()}',
                                  style: const TextStyle(color: Colors.white54 ,fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Duration: $total_duration',
                                  style: const TextStyle(color: Colors.white54 ,fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                        )
                      ]),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: const ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: data['tracks']['total'],
                      itemBuilder: (context, index){
                        var track = data['tracks']['items'][index]['track'];
                        var duration = Duration(milliseconds: track['duration_ms']).toString().substring(2, 7);
                        var artists = '';
                        var preview_url = track['preview_url'];
                        for (int i=0 ; i< track['artists'].length;i++){
                          if(i == 0){
                            artists = track['artists'][i]['name'];
                          }
                          else{
                            artists = '$artists, ${track['artists'][i]['name']}';
                          }
                        }
                        return ListView(
                          scrollDirection: Axis.vertical,
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
                              padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: Row(
                                children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 65,
                                    width: 65,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                        track['album']['images'][1]['url']
                                      ),
                                        fit: BoxFit.cover,
                                      ),
                                      ),
                                      child: Center(
                                        child: StreamBuilder(
                                          stream: audioPlayer.onPlayerStateChanged,
                                          builder: (context, snapshot){
                                            //print(snapshot.data);
                                            return ElevatedButton(
                                              onPressed: () async{
                                                if(indexSongPlaying == index){
                                                  if(audioPlayer.state == PlayerState.paused){
                                                    audioPlayer.resume();
                                                  }
                                                  else{
                                                    if(audioPlayer.state == PlayerState.playing){
                                                      audioPlayer.pause();
                                                    }
                                                    else{
                                                      await audioPlayer.play(UrlSource(track['preview_url']));
                                                    }
                                                  }
                                                }
                                                else{
                                                  if(track['preview_url'] != null){
                                                    indexSongPlaying = index;
                                                    await audioPlayer.play(UrlSource(track['preview_url']));
                                                  }
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                foregroundColor: Colors.transparent,
                                                elevation: 0,
                                              ),
                                              child: preview_url!=null ? getIcon(index) : Container()
                                          );
                                        }
                                      )
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.68,
                                        child: Text(
                                          track['name'].toString(),
                                          maxLines: 1,
                                          style: const TextStyle(color:  Colors.white, fontSize: 17, fontWeight: FontWeight.w500,overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            duration,
                                            style: const TextStyle(color: Colors.white54 ,fontSize: 14, fontWeight: FontWeight.w500,overflow: TextOverflow.fade),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Text(
                                            '-',
                                            style: TextStyle(color: Colors.white54 ,fontSize: 14, fontWeight: FontWeight.w500,overflow: TextOverflow.fade),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width*0.55,
                                            child: Text(
                                              artists,
                                              maxLines: 1,
                                              style: const TextStyle(color: Colors.white54 ,fontSize: 14, fontWeight: FontWeight.w500,overflow: TextOverflow.ellipsis),
                                            )
                                          ),
                                          
                                        ],
                                      )
                                    ],
                                  ),
                                )]
                              ),
                            )
                          ],
                        );
                      }
                    ),
                    const SizedBox(
                        height:10
                    ),
                    Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      children: [
                      FloatingActionButton.extended(
                        onPressed: () async{
                          setState(() {
                            isLoading = true;
                          });
                            var newPlaylistID = await generatePlaylist(widget.id, widget.mood, widget.length, widget.playlistID);
                            widget.playlistID = newPlaylistID;
                            playlistInfo = getPlaylistData();
                          setState(() {
                            isLoading = false;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Regenerate playlist', style: TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: spotify_dark_green,
                      ),
                      const SizedBox(
                        height:10
                      ),
                      FloatingActionButton.extended(
                        onPressed: () async{
                          final spotifyUrl = 'https://open.spotify.com/playlist/${widget.playlistID}';
                          Uri url = Uri.parse(spotifyUrl);

                          launchUrl(url,mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.arrow_circle_right_outlined),
                        label: const Text('Open Spotify', style: TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: spotify_dark_green,
                      )],
                    ),
                )]);
              }
              else{
                playlistInfo = getPlaylistData();
                return Container(
                color: Colors.black, 
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: spotify_dark_green,
                  backgroundColor: Colors.black
                  )
                );
              }
            }
          )
        )
      ),
    );
  }
}