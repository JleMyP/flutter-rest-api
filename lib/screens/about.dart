import 'package:flutter/material.dart';


class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('О программе'),
      ),
      body: Padding(
        padding: EdgeInsets.all(50),
        child: Text('Какой-то текст')
      ),
    );
  }
}
