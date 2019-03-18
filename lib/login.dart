import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'main.dart';
import 'package:dio/dio.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login>{
  TextEditingController _unameController = new TextEditingController();
  TextEditingController _pwdController = new TextEditingController();
  GlobalKey _formKey= new GlobalKey<FormState>();
  String _notice = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登陆"),
      ),
      body:Center(
        child: Form(
          key: _formKey,
          autovalidate: true, //开启自动校验
          child: Column(
          children: <Widget>[
            TextFormField(
              controller: _unameController,
              decoration: InputDecoration(
                  labelText: "用户名",
                  hintText: '您的用户名',
                  prefixIcon: Icon(Icons.person)
              ),
              validator: (v){
                if (v.contains(' ')){
                  return "不能含有空格";
                }
                if(v.length<6){
                  return "用户名长度不能少于6个字符";
                }
              },
            ),
            TextFormField(
              controller: _pwdController,
              decoration: InputDecoration(
                  labelText: "密码",
                  hintText: "您的登录密码",
                  prefixIcon: Icon(Icons.lock)
              ),
              obscureText: true,
              validator: (v){
                if(v.length<6){
                  return "密码长度不能少于6个字符";
                }
              },
            ),
            RaisedButton(
              child: Text("登陆"),
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: (){
                //请求验证
                if((_formKey.currentState as FormState).validate()){
                  //验证通过提交数据
                  print("验证通过");
                  print(_unameController.text);
                  print(_pwdController.text);
                  Dio dio=new Dio();
                  print("dioget开始");
                  print("http://39.105.207.1:5000/login/?username="+_unameController.text+"&userpwd="+_pwdController.text);
                  dio.get("http://39.105.207.1:5000/login/?username="+_unameController.text+"&userpwd="+_pwdController.text).then((Response res){
                    if(res.data.toString() == "OK"){
                      print("在OK里面");
                      getLocalFile("login.txt").then((File loginFile){
                        print("写入login.txt username");
                        loginFile.writeAsString(_unameController.text);
                      });
                      Navigator.pushNamedAndRemoveUntil(context,"主页-route",(Route<dynamic> route) => false);
                      print("返回的是"+res.data.toString());
                    }
                    else{
                      setState(() {
                        _notice = res.data.toString();
                      });
                    }
                  });
                }
                print("dioget结束");
              },
            ),
            Divider(),
            Text("若没有注册过账号，将会自动注册"),
            Divider(),
            Text(_notice),
          ],
        ),
        )
      ),
    );
  }

}