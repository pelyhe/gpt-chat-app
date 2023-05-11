import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/components/chat/typing_indicator.dart';
import 'package:project/entities/message.dart';
import 'package:project/general/fonts.dart';
import 'package:project/general/themes.dart';
import 'package:project/general/utils.dart';
import 'package:project/pages/loading.dart';
import 'package:project/services/chat_service.dart';
import 'package:project/services/user_service.dart';
import 'feedback_popup.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatController controller;
  Future? loadMessages;

  @override
  void initState() {
    super.initState();
    controller = ChatController();
    controller.id = Uri.base.queryParameters["id"]!;
    loadMessages = controller.loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.refresh(context);
    return FutureBuilder(
        future: loadMessages,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingPage();
          } else {
            return GetBuilder<ChatController>(
                init: controller,
                builder: (controller) {
                  return Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: true,
                      title: const Text(
                          "Hello Chat GPT (Beta) powered by Walter's Cube"),
                      backgroundColor: AppColors.appBarColor.withOpacity(0.9),
                    ),
                    body: scaffoldBody(
                      context: context,
                      mobileBody: _mobileBody(),
                      tabletBody: _tabletBody(),
                      desktopBody: _desktopBody(),
                    ),
                  );
                });
          }
        });
  }

  Widget _mobileBody() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: ScreenSize.width * 0.05),
        child: _createBody());
  }

  Widget _tabletBody() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: ScreenSize.width * 0.15),
        child: _createBody());
  }

  Widget _desktopBody() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: ScreenSize.width * 0.27),
        child: _createBody());
  }

  Widget _createBody() {
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          child: Column(children: [
            for (var message in controller.messages!)
              message.isSentByMe
                  ? _createSentChatBubble(message)
                  : _createRecievedChatBubble(message),
          ]),
        ),
      ),
      Align(
        alignment: Alignment.bottomLeft,
        child: TypingIndicator(
          showIndicator: controller.isWaitingForAnswer,
          bubbleColor: AppColors.grey!,
        ),
      ),
      Align(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(AppColors.appBarColor)),
                onPressed: () => controller.getUserCategory(context),
                child: const Text("What type of collector am I?")),
          ),
          _createMessageBar(),
        ],
      ))
    ]);
  }

  Widget _createSentChatBubble(Message message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ChatBubble(
            clipper: ChatBubbleClipper7(type: BubbleType.sendBubble),
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(top: 20),
            backGroundColor: Colors.yellow[200],
            child: Container(
              constraints: BoxConstraints(
                maxWidth: ScreenSize.width * 0.7,
              ),
              child: Text(
                message.text,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: createAvatarFromName(18.0, 'User', 0),
        ),
      ],
    );
  }

  Widget _createRecievedChatBubble(Message message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: createAvatarFromName(18.0, 'Artificial Intelligence', 0),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: ChatBubble(
            clipper: ChatBubbleClipper7(type: BubbleType.receiverBubble),
            backGroundColor: AppColors.grey,
            margin: const EdgeInsets.only(top: 20),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: ScreenSize.width * 0.7,
              ),
              child: Text(
                message.text,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.feedback),
          onPressed: () => {
            showDialog(
                context: context,
                builder: (BuildContext ctx) => FeedbackPopup(message: message))
          },
        ),
      ],
    );
  }

  Widget _createMessageBar() {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                  controller: controller._textFieldController,
                  decoration: InputDecoration(
                    fillColor: AppColors.grey,
                    hintText: "Type your message here...",
                    hintStyle: const TextStyle(color: Colors.black),
                  ),
                  onSubmitted: (value) async {
                    final message = Message(
                        text: value, date: DateTime.now(), isSentByMe: true);
                    controller._textFieldController.clear();
                    setState(() {
                      controller.messages!.add(message);
                      controller.isWaitingForAnswer = true;
                    });
                    await controller.sendMessage(context, message);
                  }),
            ),
            const SizedBox(
              width: 10,
            ),
            MaterialButton(
              color: AppColors.appBarColor,
              onPressed: () async {
                final message = Message(
                    text: controller._textFieldController.text,
                    date: DateTime.now(),
                    isSentByMe: true);
                controller._textFieldController.clear();
                setState(() {
                  controller.messages!.add(message);
                  controller.isWaitingForAnswer = true;
                });
                await controller.sendMessage(context, message);
              },
              child: Row(
                children: const [
                  Text("Send now", style: TextStyle(color: Colors.white)),
                  SizedBox(width: 10),
                  Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
              elevation: 0,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatController extends GetxController {
  ChatService chatService = ChatService();
  UserService userService = UserService();
  late String id;
  List<Message>? messages = [];
  final _textFieldController = TextEditingController();
  bool isWaitingForAnswer = false;

  loadMessages() async {
    messages = await userService.getPreviousMessagesByUserId(id);
    update();
  }

  Future<void> sendMessage(BuildContext context, Message message) async {
    // send text to rest api
    final response = await chatService.askChatbot(message.text, id);
    // add response to messages
    if (response != null) {
      messages!.add(
          Message(date: DateTime.now(), text: response, isSentByMe: false));
    } else {
      const snackBar = SnackBar(
        content:
            Text("Cannot communicate with AI.", style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    isWaitingForAnswer = false;
    update();
  }

  Future<void> getUserCategory(BuildContext context) async {
    String text = "";
    String prompt = "";
    if (messages!.isEmpty) {
      text =
          "Cannot determine the collector's category without previous messages.";

      final snackBar = SnackBar(
        content: Text(text, style: const TextStyle(fontSize: 20)),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else if (messages!.length < 11) {
      List<String> myMessages = [];
      for (var m in messages!) {
        if (m.isSentByMe) {
          myMessages.add(m.text);
        }
      }
      prompt = myMessages.join(" | ");
    } else {
      List<String> myMessages = [];
      for (var m in messages!) {
        if (m.isSentByMe) {
          myMessages.add(m.text);
        }
      }
      final lastMessages = myMessages.sublist(myMessages.length - 5);
      prompt = lastMessages.join(" | ");
    }

    final result = await userService.getUserCategory(prompt);

    if (result!.toLowerCase().contains("investor")) {
      text = "You are an investor!";
    } else if (result.toLowerCase().contains("impulsive")) {
      text = "You are an impulsive collector!";
    } else if (result.toLowerCase().contains("thematic")) {
      text = "You are a thematic collector!";
    } else if (result.toLowerCase().contains("lover")) {
      text = "You are an art lover!";
    }

    final snackBar = SnackBar(
      content: Text(text, style: const TextStyle(fontSize: 20)),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
