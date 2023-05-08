import 'package:flutter/material.dart';

class ApiScreen extends StatelessWidget {
  const ApiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API 설정'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text('test'),
      ),
    );
  }
}
