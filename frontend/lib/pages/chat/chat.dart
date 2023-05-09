import 'dart:convert';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/entities/message.dart';
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
                      title: const Text('GPT Chat'),
                      backgroundColor: AppColors.appColorBlue.withOpacity(0.9),
                    ),
                    body: scaffoldBody(
                      context: context,
                      mobileBody: _mobileBody(),
                      tabletBody: _mobileBody(),
                      desktopBody: _desktopBody(),
                    ),
                  );
                });
          }
        });
  }

  Widget _mobileBody() {
    return Stack(children: [
      SingleChildScrollView(
        child: Column(children: [
          for (var message in controller.messages!)
            BubbleNormal(
              text: message.text,
              color: message.isSentByMe ? AppColors.blue : Colors.grey.shade300,
              isSender: message.isSentByMe,
              textStyle: TextStyle(
                  color: message.isSentByMe ? Colors.white : Colors.black),
            ),
          const SizedBox(height: 70)
        ]),
      ),
      MessageBar(
        sendButtonColor: AppColors.appColorBlue,
        onSend: (text) async {
          final message =
              Message(text: text, date: DateTime.now(), isSentByMe: true);
          setState(() {
            controller.messages!.add(message);
          });
          await controller.sendMessage(context, message);
        },
      )
    ]);
  }

  Widget _desktopBody() {
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          child: Column(children: [
            for (var message in controller.messages!)
              Row(
                children: [
                  if (message.isSentByMe == false)
                    IconButton(
                      icon: const Icon(Icons.feedback),
                      onPressed: () => {
                        showDialog(
                            context: context,
                            builder: (BuildContext ctx) => FeedbackPopup(message: message))
                      },
                    ),
                  Expanded(
                    child: BubbleNormal(
                      text: utf8.decode(message.text.codeUnits),
                      color: message.isSentByMe
                          ? AppColors.blue
                          : Colors.grey.shade300,
                      isSender: message.isSentByMe,
                      textStyle: TextStyle(
                          color:
                              message.isSentByMe ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
          ]),
        ),
      ),
      Align(
          child: Column(
        children: [
          ElevatedButton(
              onPressed: () => controller.getUserCategory(context),
              child: const Text("What type of collector am I?")),
          MessageBar(
            sendButtonColor: AppColors.appColorBlue,
            onSend: (text) async {
              final message =
                  Message(text: text, date: DateTime.now(), isSentByMe: true);
              setState(() {
                controller.messages!.add(message);
              });
              await controller.sendMessage(context, message);
            },
          ),
        ],
      ))
    ]);
  }
}

class ChatController extends GetxController {
  ChatService chatService = ChatService();
  UserService userService = UserService();
  late String id;
  List<Message>? messages = [];

  loadMessages() async {
    messages = await userService.getPreviousMessagesByUserId(id);
    for (var m in messages!) {
      //print(m.text);
    }
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
    update();
  }

  Future<void> getUserCategory(BuildContext context) async {
    String text = "";
    String prompt = "";
    if (messages!.isEmpty) {
      text =
          "Cannot determine the collector's category without previous messages.";
    } else if (messages!.length < 5) {
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
