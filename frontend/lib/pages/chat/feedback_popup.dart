import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../entities/message.dart';
import '../../entities/fb.dart';
import '../../general/fonts.dart';
import '../../services/feedback_service.dart';

class FeedbackPopup extends StatefulWidget {
  Message? message;
  FeedbackPopup({Key? key, required this.message}) : super(key: key);

  @override
  State<FeedbackPopup> createState() => _FeedbackPopupState();
}

class _FeedbackPopupState extends State<FeedbackPopup> {
  TextEditingController feedbackField = TextEditingController();
  final controller = Get.put(FeedbackPopupController());
  List<String> checkedItems = [];
  Message? message;

  @override
  Widget build(BuildContext context) {
    ScreenSize.refresh(context);
    message = widget.message;
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
                  hintText: 'Provide Feedback',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 10, vertical: 10),
              child: checkboxes(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 10, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  controller.feedback = Fb(text: message!.text, feedback: feedbackField.text, opinion: checkedItems, date: message!.date);
                  controller.sendFeedback();
                  //controller.feedbackService.upload(type!, feedbackField.text);
                  //print('Message: ' + controller.feedback!.text+'\n'
                  //+ controller.feedback!.feedback +'\n'
                  //+ controller.feedback!.opinion.toString() +'\n'
                  //+controller.feedback!.date.toString() +'\n'+ 'Feedback saved');
                },
                child: Text("Submit".toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row checkboxes() {
    return Row(children: [
      checkbox('Relevant', true),
      checkbox('Irrelevant', false),
      checkbox('Repetitive', false),
      checkbox('Out of context', false),
      checkbox('convincing', false),
      checkbox('Intresting', false),
    ]);
  }

  Expanded checkbox(String title, bool leading) {
    return Expanded(
      child: CheckboxListTile(
          title: Text(title),
          value: checkedItems.contains(title),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                checkedItems.add(title);
              } else {
                checkedItems.remove(title);
              }
            });
          },
        ),

    );
  }
}

class FeedbackPopupController extends GetxController {
  final feedbackService = FeedbackService();
  Fb? feedback;
  sendFeedback(){
    feedbackService.upload(feedback!);
  }
}
