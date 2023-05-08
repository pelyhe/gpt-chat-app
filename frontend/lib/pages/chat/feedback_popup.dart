import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../general/fonts.dart';
import '../../services/feedback_service.dart';

class FeedbackPopup extends StatefulWidget {
  String? type;
  FeedbackPopup({Key? key, required this.type}) : super(key: key);

  @override
  State<FeedbackPopup> createState() => _FeedbackPopupState();
}

class _FeedbackPopupState extends State<FeedbackPopup> {
  TextEditingController feedbackField = TextEditingController();
  final controller = Get.put(FeedbackPopupController());
  String? type;

  @override
  Widget build(BuildContext context) {
    ScreenSize.refresh(context);
    type = widget.type;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SizedBox(
        height: ScreenSize.height * 0.25,
        width: ScreenSize.width * 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 10, vertical: 10),
              child: TextField(
                controller: feedbackField,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Feedback',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 10, vertical: 10),
              child: 
              checkboxes(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 10, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  //controller.feedbackService.upload(type!, feedbackField.text);
                  print('Type: ' + type! + 'Feedback saved');
                  print(controller.type?.toSet().toString());
                },
                child: Text("Sumbit".toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row checkboxes(){
    return Row(
      children: [
        checkbox('Relevant', true),
        checkbox('Irrelevant', false),
        checkbox('Repetitive', false),
        checkbox('Out of context', false),
        checkbox('convincing', false),
        checkbox('Intresting', false),
      ]);
  }
  Expanded checkbox(String title, bool leading){
    return Expanded(
      child: CheckboxListTile(
      title: Text(title),
      value: controller.checkedValue,
      onChanged: (newValue) {
        setState(() {
          controller.checkedValue = newValue!;
          controller.setType(title);
        });
      },
      controlAffinity: leading ? ListTileControlAffinity.leading : ListTileControlAffinity.trailing, 
      ),
    );
  }
}
//every box is selected when one is
class FeedbackPopupController extends GetxController {
  final feedbackService = FeedbackService();
  bool checkedValue = false;
  List<String>? type = [];
  setType(String t){
    type?.add(t);
  }
  sendFeedback() {}
}
