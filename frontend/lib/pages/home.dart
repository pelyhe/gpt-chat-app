import 'package:flutter/material.dart';
import 'package:project/general/route.dart';
import 'package:project/general/themes.dart';
import 'package:project/general/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPT Chat'),
        backgroundColor: AppColors.appColorBlue,
      ),
      body: scaffoldBody(
        context: context,
        mobileBody: _mobileBody(),
        tabletBody: _mobileBody(),
        desktopBody: _desktopBody(),
      ),
    );
  }

  Widget _mobileBody() {
    return Center(
      child: ElevatedButton(
        child: const Text('Start conversation'),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.chat), 
      ),
    );
  }

  Widget _desktopBody() {
    return Center(
      child: ElevatedButton(
        child: const Text('Start conversation'),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.chat), 
      ),
    );
  }

}
