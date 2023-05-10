import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../entities/message.dart';
import '../../entities/fb.dart';
import '../../general/fonts.dart';
import '../../services/feedback_service.dart';

// ignore: must_be_immutable
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
        height: ScreenSize.isDesktop ? ScreenSize.height * 0.33 : ScreenSize.height * 0.5,
        width: ScreenSize.width * 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal:  8, vertical: 10),
              child: TextField(
                controller: feedbackField,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Tell me your opinion about the response',
                  fillColor: Colors.grey[200]!
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
                onPressed: () async {
                  controller.feedback = Fb(text: message!.text, feedback: feedbackField.text, opinion: checkedItems, date: message!.date);
                  await controller.sendFeedback();
                  Navigator.pop(context);
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

  Widget checkboxes() {
    return Wrap(children: [
      checkbox('Relevant', true),
      checkbox('Irrelevant', false),
      checkbox('Repetitive', false),
      checkbox('Out of context', false),
      checkbox('Convincing', false),
      checkbox('Intresting', false),
    ]);
  }

  Widget checkbox(String title, bool leading) {
    return SizedBox(
      width: 180,
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
  Future<void> sendFeedback() async {
    await feedbackService.upload(feedback!);
  }
}
