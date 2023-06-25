import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playlist_generator/pages/playlist_generator.dart';
import 'package:playlist_generator/pages/signin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assets/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void setSignoutID() async{
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('id', 'None');
}

class AccountStatsPage extends StatefulWidget {
  final String id;
  const AccountStatsPage({Key? key, required this.id}) : super(key:key);

  @override
  State<AccountStatsPage> createState() => _AccountStatsPageState();
}

class _AccountStatsPageState extends State<AccountStatsPage>{
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState(){
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

@override
Widget build(BuildContext context) {
    
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
        leading: Builder(
        builder: (context) => IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: spotify_black,
        elevation: 20.0,
        title: const Text('Playlists by moods and lengths'),
      ),
        body: SingleChildScrollView(
        child :Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/assets/images/mood-background-texture.jpg"),
                fit: BoxFit.fill,
              )
            ),
            child: Column(children: [
                SizedBox(
                  height: 750,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('users').doc(widget.id).snapshots(),
                    builder: (context, snapshot){
                      if(snapshot.hasData){
                        var data = snapshot.data!.data();
                        if(data?['playlistsCreated']['total'] > 0){
                          var moodChartData = getMoodChartData(data!['playlistsCreated']);
                          var lengthsChartData = getLengthChartData(data['playlistsCreated']);
                          return ListView(
                            children: [
                              SfCircularChart(
                              tooltipBehavior: _tooltipBehavior,
                              palette: const <Color>[Color.fromARGB(255, 229, 205, 87), Color.fromARGB(255, 96, 172, 234), Color.fromARGB(255, 82, 207, 86), Color.fromARGB(255, 229, 98, 98)],
                              series: <CircularSeries>[
                                RadialBarSeries<generatedData, String>(
                                  trackOpacity: 0.2,
                                  dataSource: moodChartData,
                                  xValueMapper: (generatedData data, _) => data.mood,
                                  yValueMapper: (generatedData data, _) => data.count,
                                  enableTooltip: true,
                                  dataLabelSettings: const DataLabelSettings(
                                    textStyle: TextStyle(color: white, fontSize: 12, fontWeight: FontWeight.w500),
                                    isVisible: true,
                                  ),
                                  animationDuration: 2000,
                                  animationDelay: 500,
                                  maximumValue: getMaxValue(data['playlistsCreated']['moods'])
                                )
                              ],
                              legend: Legend(
                                position: LegendPosition.bottom,
                                isVisible: true,
                                overflowMode: LegendItemOverflowMode.wrap,
                                textStyle: const TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.w500)
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              SfCircularChart(
                              tooltipBehavior: _tooltipBehavior,
                              palette: const <Color>[Colors.yellow, Colors.blue, Colors.green, Colors.redAccent, Colors.orange, Colors.purple, Colors.indigo],
                              series: <CircularSeries>[
                                DoughnutSeries<generatedData, String>(
                                  dataSource: lengthsChartData,
                                  xValueMapper: (generatedData data, _) => data.mood,
                                  yValueMapper: (generatedData data, _) => data.count,
                                  enableTooltip: true,
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                  ),
                                  animationDuration: 2000,
                                  animationDelay: 500,
                                )
                              ],
                              legend: Legend(
                                position: LegendPosition.bottom,
                                isVisible: true,
                                overflowMode: LegendItemOverflowMode.wrap,
                                textStyle: const TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.w500)
                                ),
                              )
                            ],
                          );
                        }
                        else{
                          return Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'No data yet',
                            style: TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.w500)
                            )
                          );
                        }
                      }
                      else{
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
                ),
              )
            ],
            )
        ),
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
              height: 290,
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
      )
    );
  }
  List<generatedData> getMoodChartData(Map<String,dynamic> data){
    final List<generatedData> chartData = [
      generatedData('Happy', data['moods']['happy']),
      generatedData('Sad', data['moods']['sad']),
      generatedData('Relaxed', data['moods']['relaxed']),
      generatedData('Angry', data['moods']['angry']),
    ];
    return chartData;
  }

  List<generatedData> getLengthChartData(Map<String,dynamic> data){
    final List<generatedData> chartData = [
      generatedData('30', data['lengths']['30 min']),
      generatedData('45', data['lengths']['45 min']),
      generatedData('60', data['lengths']['60 min']),
      generatedData('90', data['lengths']['90 min']),
      generatedData('120', data['lengths']['120 min']),
      generatedData('150', data['lengths']['150 min']),
      generatedData('180', data['lengths']['180 min']),
    ];
    return chartData;
  }

  double getMaxValue(Map<String,dynamic> data){
    var maxValue = 0;
    data.forEach((key, value) {
      if(value > maxValue){
        maxValue=value;
      }
    });
    return maxValue.toDouble();
  }
}


class generatedData {
  generatedData(this.mood, this.count);
  final String mood;
  final int count;
}