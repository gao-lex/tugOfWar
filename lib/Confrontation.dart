import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:sensors/sensors.dart';
import 'main.dart';
import 'dart:io';
//
//
class Confrontation extends StatefulWidget {
  @override
  _ConfrontationStateLoding createState() => _ConfrontationStateLoding();
}

class _ConfrontationStateLoding extends State<Confrontation> {
  List<double> _userAccelerometerValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
  <StreamSubscription<dynamic>>[];


  bool _isFindDone = false;

  String _oppositeUserName = "";
  int _oppositeUserShakeTimes = 0;
  String _username = "";
  int _shakeTimes = 0;
  Timer timeout;
  bool canShake = true;
  String _winer = "";
  Dio dio = new Dio();
  String _notice ="";
  bool _sendMatchRequest = false;

  @override
  void initState(){
    super.initState();
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));

    getLocalFile("login.txt").then((File loginFile){
        print("读login.txt里面的username");
        _username = loginFile.readAsStringSync();
        dio.get("http://39.105.207.1:5000/giveMeOppositeUser/?username="+_username).then((Response resOppositeUser){
          print("请求到了对手名字");
          _oppositeUserName = resOppositeUser.data.toString();
          _isFindDone = true;
          _sendMatchRequest = true;
        });
    });

  }

  @override
  void dispose(){
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    dio.get("http://39.105.207.1:5000/resetDict/?username1="+_username+"&username2="+_oppositeUserName).then((Response res){

    });
  }


  Scaffold matching (){


    if(_oppositeUserShakeTimes == 100 || _shakeTimes == 100) {
      _winer = (_oppositeUserShakeTimes > _shakeTimes) ? _oppositeUserName :_username;
      canShake = false;
      setState(() {
        _notice = _winer+"赢了";
      });
    }

    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();
    if(userAccelerometer == null || !canShake){

    }
    else{
      dio.get("http://39.105.207.1:5000/oppositeUserShakeTimes/?username="+_oppositeUserName).then((Response resOppositeUserShakeTimes){
        _oppositeUserShakeTimes = int.parse(resOppositeUserShakeTimes.data.toString());
      });
      double _x = _userAccelerometerValues[0];
      double _y = _userAccelerometerValues[1];
      double _z = _userAccelerometerValues[2];
      if( _x.abs()>15||_y.abs()>15||_z.abs()>15){
        setState(() {
          _shakeTimes++;
          dio.get("http://39.105.207.1:5000/oppositeUserShakeTimesAdd/?username="+_username).then((Response setMyShakeTime){
          });
        });
      }
    }

    return new Scaffold(
      appBar: AppBar(
        title: Text("对战ing"),
      ),

      body: Column(
        children: <Widget>[
          Divider(),
          Icon(
            Icons.videogame_asset,
            size: 200.0,
          ),

          Divider(

          ),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  title:  Text("您",
                    textAlign: TextAlign.left,
                    textScaleFactor:2.0,),
                  subtitle: Text(
                      '摇动次数：$_shakeTimes'
                  ),
                ),
                LinearProgressIndicator(
                  value: double.parse(_shakeTimes.toString())/100,
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  title:  Text(_oppositeUserName,
                    textAlign: TextAlign.left,
                    textScaleFactor:2.0,),
                  subtitle: Text(
                      '摇动次数：'+_oppositeUserShakeTimes.toString()
                  ),
                ),
                LinearProgressIndicator(
                  value: double.parse(_oppositeUserShakeTimes.toString())/100,
                ),

              ],
            ),
          ),
          Text(_notice),
          ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    print("_isFindDone:$_isFindDone");
    return _isFindDone?matching():Loding("正在寻找对手");
  }


  //刚进入时圆形进度条表示正在寻找对手。向服务器发出匹配请求，等待接受请求
//收到请求后初始化比赛界面，双方都准备后倒计时进入比赛
//
  Scaffold Loding(String lodingInfo){
      return new Scaffold(
        appBar: AppBar(
          title: Text(lodingInfo),
        ),
        body:Center(child: CircularProgressIndicator(),),
      );
  }
}
