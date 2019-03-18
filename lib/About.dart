import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("关于我们"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("高磊"),
            Text("李浩然"),
            Text("靳治森"),
            Text("乔宏楷"),
            Text("刘凯"),
          ],
        ),
      ),
    );
  }

}
