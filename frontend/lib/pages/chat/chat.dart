import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:project/entities/message.dart';
import 'package:project/general/themes.dart';
import 'package:project/general/utils.dart';
import 'package:intl/intl.dart';
import 'package:project/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = ChatController();

  @override
  Widget build(BuildContext context) {
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

  Widget _mobileBody() {
    return Column(children: [
      Expanded(
          child: GroupedListView<Message, DateTime>(
              reverse: true,
              order: GroupedListOrder.DESC,
              useStickyGroupSeparators: true,
              floatingHeader: true,
              elements: controller.messages,
              padding: const EdgeInsets.all(8),
              groupBy: (message) => DateTime(
                  message.date.year, message.date.month, message.date.day),
              groupHeaderBuilder: (Message message) => SizedBox(
                    height: 40,
                    child: Center(
                      child: Card(
                        color: AppColors.appColorBlue,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(DateFormat.yMMMd().format(message.date),
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
              itemBuilder: (context, Message message) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.5),
                    child: BubbleNormal(
                      text: message.text,
                      color: message.isSentByMe
                          ? AppColors.blue
                          : Colors.grey.shade300,
                      isSender: message.isSentByMe,
                      textStyle: TextStyle(
                          color:
                              message.isSentByMe ? Colors.white : Colors.black),
                    ),
                  ))),
      Container(
          color: Colors.grey.shade300,
          child: MessageBar(
            sendButtonColor: AppColors.appColorBlue,
            onSend: (text) async {
              final message =
                  Message(text: text, date: DateTime.now(), isSentByMe: true);
              setState(() {
                controller.messages.add(message);
              });
              await controller.sendMessage(context, message);
            },
            onTextChanged: (p0) async {
              if (p0.endsWith('\n')) {
                final message =
                    Message(text: p0, date: DateTime.now(), isSentByMe: true);
                setState(() {
                  controller.messages.add(message);
                });
                await controller.sendMessage(context, message);
              }
            },
          ))
    ]);
  }

  Widget _desktopBody() {
    return Column(children: [
      Expanded(
          child: GroupedListView<Message, DateTime>(
              reverse: true,
              order: GroupedListOrder.DESC,
              useStickyGroupSeparators: true,
              floatingHeader: true,
              elements: controller.messages,
              padding: const EdgeInsets.all(8),
              groupBy: (message) => DateTime(
                  message.date.year, message.date.month, message.date.day),
              groupHeaderBuilder: (Message message) => SizedBox(
                    height: 40,
                    child: Center(
                      child: Card(
                        color: AppColors.appColorBlue,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(DateFormat.yMMMd().format(message.date),
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
              itemBuilder: (context, Message message) => BubbleNormal(
                    text: message.text,
                    color: message.isSentByMe
                        ? AppColors.blue
                        : Colors.grey.shade300,
                    isSender: message.isSentByMe,
                    textStyle: TextStyle(
                        color:
                            message.isSentByMe ? Colors.white : Colors.black),
                  ))),
      Container(
          color: Colors.grey.shade300,
          child: MessageBar(
            sendButtonColor: AppColors.appColorBlue,
            onSend: (text) async {
              final message =
                  Message(text: text, date: DateTime.now(), isSentByMe: true);
              setState(() {
                controller.messages.add(message);
              });
              await controller.sendMessage(context, message);
            },
          ))
    ]);
  }
}

class ChatController extends GetxController {
  ChatService chatService = ChatService();

  List<Message> messages = [];

  Future<void> sendMessage(BuildContext context, Message message) async {
    // send text to rest api
    final response = await chatService.askChatbot(message.text);
    // add response to messages
    if (response != null) {
      messages.add(
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
}
