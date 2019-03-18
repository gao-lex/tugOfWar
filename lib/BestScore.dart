import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sensors/sensors.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BestScore extends StatefulWidget{
  @override
  _BestScore createState() => _BestScore();
}

class _BestScore extends State<BestScore>{
  int _times = -1;
  String _username = "";
  @override

  void initState() {
    super.initState();
    getLocalFile("login.txt").then((File loginFile) {
      setState(() {
        _username = loginFile.readAsStringSync();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_username!="" && _times == -1){
      Dio dio = new Dio();
      dio.get("http://39.105.207.1:5000/bestShakeScore/?username="+_username).then((Response res){
        setState(() {
          _times = int.parse(res.data.toString());
        });
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("最好成绩"),
      ),
      body: Center(

        child: Text("您的最好成绩为$_times次/分钟"),
      ),
    );
  }
}

//参数：文件名
//返回：文件
Future<File> getLocalFile( String path ) async{
  String dirRoot = (await getApplicationDocumentsDirectory()).path;
  String dirWant = dirRoot+'/'+path;
  return new File(dirWant);
}