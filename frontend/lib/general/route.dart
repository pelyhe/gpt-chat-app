import 'package:get/get.dart';
import 'package:project/pages/chat/chat.dart';
import 'package:project/pages/home.dart';

class AppRoutes {
//route with parameters example:
//    - static String myPage({required id}) => "mypage/:$id";
//    - :$id will be the parameter
//
//    - GetPage(
//          name: myPage(
//              id: '${MyPageScreen.idParameter}'),
//          page: () => MyPageScreen()),
//
//    - in the widget where the route goes should be a static String idParameter="<key>"
//    - get the parameter by Get.parameters[MyPageScreen.idParameter]
  static String home = "/";
  static String chat = "/chat";

  static final pages = [
    GetPage(name: home, page: () => const HomePage()),
    GetPage(name: chat, page: () => const ChatPage())
  ];
}
