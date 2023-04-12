import 'package:flutter/material.dart';
import 'package:project/general/fonts.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    ScreenSize.refresh(context);
    return PreferredSize(
      preferredSize: Size(ScreenSize.width, kToolbarHeight),
      child: AppBar(
        title: const Text('GPT chat'),
      ),
    );
  }
}