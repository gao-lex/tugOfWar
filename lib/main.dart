import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'Practice.dart';
import 'Confrontation.dart';
import 'login.dart';
import 'BestScore.dart';
import 'About.dart';

void main(){
  runApp(Home());
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}


class _HomeState extends State<Home>{

  bool _isLogin = false;


  @override
  void initState(){
    super.initState();
    checkLogin().then((bool isLogin){
      setState(() {
        _isLogin = isLogin;
        print("_isLogin:$_isLogin");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '手机拔河',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        "登陆-route":(content)=>Login(),
        "主页-route":(content)=>MyHomePage(),
        "练习模式-route":(content)=>Practice(),
        "联机对战-route":(content)=>Confrontation(),
        "比赛记录-page":(content)=>Practice(),
        "最高成绩-route":(content)=>BestScore(),
        "关于我们-route":(content)=>AboutUs(),
      },
      home: _isLogin?MyHomePage():Login(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _username = "";

  @override
  void initState(){
    super.initState();
    getLocalFile("login.txt").then((File loginFile){
      setState(() {
        print("读login.txt里面的username");
        _username = loginFile.readAsStringSync();
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    if(_username == ""){
      getLocalFile("login.txt").then((File loginFile){
        setState(() {
          print("读login.txt里面的username");
          _username = loginFile.readAsStringSync();
        });
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("tug of war\'s Home"),
      ),
      drawer: Drawer(
        semanticLabel: "抽屉",
        elevation: 1000,
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(

                accountName: Text(_username),
                accountEmail: Text(_username+"@tugOfWar.com")
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("登出"),
              onTap: (){
                getLocalFile("login.txt").then((File loginFile){
                  print("把login.txt清空");
                  loginFile.writeAsString("");
                  Navigator.pushNamedAndRemoveUntil(context,"登陆-route",(Route<dynamic> route) => false);
                });
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.grade),
              title: Text("最高成绩"
              ),
              onTap: (){
                Navigator.pushNamed(context, "最高成绩-route");
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.supervisor_account),
              title: Text("关于我们"),
              onTap: (){
                Navigator.pushNamed(context, "关于我们-route");
              },
            ),
          ],
        )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                color: Colors.blue,
                highlightColor: Colors.blue[700],
                colorBrightness: Brightness.dark,
                splashColor: Colors.grey,
                child: Text(
                    "🤺 练习模式",
                  textScaleFactor: 1.9,
                ),
                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                onPressed: () {
                    Navigator.pushNamed(context, "练习模式-route");
                }
              ),

            RaisedButton(
                color: Colors.blue,
                highlightColor: Colors.blue[700],
                colorBrightness: Brightness.dark,
                splashColor: Colors.grey,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[

                    Text(
                        "⚔  联机对战",
                      textScaleFactor: 2.0,
                    ),
                  ],
                ),

                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                onPressed: () {
                  Navigator.pushNamed(context, "联机对战-route");
                },
              )
          ],
        ),
      ),
    );
  }
}

Future<bool> checkLogin() async{
  try {
    File loginFile = (await getLocalFile("login.txt"));
    String loginInfo = (await loginFile.readAsString());
    print("loginInfo:$loginInfo");
    if (loginInfo == "")
      return false;
    else
      return true;
  }on FileSystemException {
    return false;
  }
}

//参数：文件名
//返回：文件
Future<File> getLocalFile( String path ) async{
    String dirRoot = (await getApplicationDocumentsDirectory()).path;
    String dirWant = dirRoot+'/'+path;
    return new File(dirWant);
}