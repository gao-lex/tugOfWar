import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sensors/sensors.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class Practice extends StatefulWidget {
  @override
  _PracticeState createState() => _PracticeState();
}

class _PracticeState extends State<Practice> {
  List<double> _userAccelerometerValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
  <StreamSubscription<dynamic>>[];
  int _shakeTimes = 0;
  Timer timeout;
  bool canShake = true;
  String _username = "";
  String _notice = "";
  int oldBestScore = -1;



  @override
  Widget build(BuildContext content){

    if(_username!="" && oldBestScore ==-1){
      Dio dio = new Dio();
      dio.get("http://39.105.207.1:5000/bestShakeScore/?username="+_username).then((Response res){
        setState(() {
          oldBestScore = int.parse(res.data.toString());
        });
      });
    }


    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();

    if(userAccelerometer == null || !canShake){

    }
    else{
      double _x = _userAccelerometerValues[0];
      double _y = _userAccelerometerValues[1];
      double _z = _userAccelerometerValues[2];
      if( _x.abs()>15||_y.abs()>15||_z.abs()>15){
        setState(() {
          _shakeTimes++;
        });
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('练习模式'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("您的历史最好成绩为$oldBestScore"),
                Text("请在一分钟内尽可能多地晃动手机"),
                LinearProgressIndicator(
                  value: double.parse(_shakeTimes.toString())/100,
                ),
                Text('摇动次数：$_shakeTimes'),
                Text(_notice)
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
        ],
      ),
    );

  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    timeout.cancel();
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    getLocalFile("login.txt").then((File loginFile){
      getLocalFile("login.txt").then((File loginFile) {
        setState(() {
          _username = loginFile.readAsStringSync();
        });
      });
    });




    timeout = new Timer(const Duration(seconds: 60),(){
      setState(() {
        canShake = false;
        if(oldBestScore < _shakeTimes){
          Dio dio = new Dio();
          dio.get("http://39.105.207.1:5000/setBestShakeScore/?username="+_username+'&times='+_shakeTimes.toString()).then( (Response setRe){
            if(setRe.data.toString() == "OK"){
              setState(() {
                _notice = "已更新您的最好成绩为$_shakeTimes";
              });
            }
          } );
        }
        });
      });

  }
}

Scaffold Loding(String lodingInfo){
  return new Scaffold(
    appBar: AppBar(
      title: Text(lodingInfo),
    ),
    body:Center(child: CircularProgressIndicator(),),
  );
}

//参数：文件名
//返回：文件
Future<File> getLocalFile( String path ) async{
  String dirRoot = (await getApplicationDocumentsDirectory()).path;
  String dirWant = dirRoot+'/'+path;
  return new File(dirWant);
}
