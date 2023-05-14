import 'package:get/get.dart';
import 'package:project/pages/auth/login_screen.dart';
import 'package:project/pages/auth/sign_up_screen.dart';
import 'package:project/pages/chat/chat.dart';
import 'package:project/pages/home.dart';
import 'package:project/pages/preference/preference_quiz.dart';


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
  static String login = '/login';
  static String signUp = '/register';
  //Preferences Routes
  static String location({required id}) => '/location/:$id';

  static final pages = [
    GetPage(name: home, page: () => const HomePage()),
    GetPage(name: chat, page: () => const ChatPage()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signUp, page: () => const SignUpScreen()),
    //Preferences Pages
    GetPage(name: location(id: PreferenceQuizPage.idParameterName), page: () => const PreferenceQuizPage()),
  ];
}
