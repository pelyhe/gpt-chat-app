import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../general/fonts.dart';
import '../../general/themes.dart';

class FeedbackPopup extends StatefulWidget {
  String? type;
  FeedbackPopup({Key? key, required this.type}) : super(key: key);

  @override
  State<FeedbackPopup> createState() => _FeedbackPopupState();
}

class _FeedbackPopupState extends State<FeedbackPopup> {
  final controller = Get.put(FeedbackPopupController());
  String? type;
  @override
  Widget build(BuildContext context) {
    ScreenSize.refresh(context);
    type = widget.type;
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0)), //this right here
      child: SizedBox(
        height: ScreenSize.height * 0.15,
        width: ScreenSize.width * 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 10, vertical: 10),
              child: const TextField(
                //controller: countryField,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Feedback',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 10, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  print('Type: ' + type! + 'Feedback saved');
                },
                child: Text("Sumbit".toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackPopupController extends GetxController {
  sendFeedback() {}
}
