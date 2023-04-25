import 'package:get/get.dart';
import 'package:project/pages/auth/login_screen.dart';
import 'package:project/pages/auth/sign_up_screen.dart';
import 'package:project/pages/chat/chat.dart';
import 'package:project/pages/home.dart';
import 'package:project/pages/preference/favourite_artist.dart';
import 'package:project/pages/preference/favourite_artworks.dart';
import 'package:project/pages/preference/favourite_galleries.dart';
import 'package:project/pages/preference/job_action_fairs.dart';
import 'package:project/pages/preference/location.dart';
import '../pages/preference/purchased_artworks.dart';

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
  static String location ='/location';
  static String favArtwork ='/favouriteArtwork';
  static String favGallery ='/favouriteGallery';
  static String favArtist ='/favouriteArtist';
  static String purchasedArtwork ='/purchasedArtwork';
  static String jobAuctionFair ='/jobAuctionFair';

  static final pages = [
    GetPage(name: home, page: () => const HomePage()),
    GetPage(name: chat, page: () => const ChatPage()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signUp, page: () => const SignUpScreen()),
    //Preferences Pages
    GetPage(name: location, page: () => const LocationPage()),
    GetPage(name: favArtwork, page: () => const FavouriteArtWorksPage()),
    GetPage(name: favGallery, page: () => const FavouriteGalleriesPage()),
    GetPage(name: favArtist, page: () => const FavouriteArtistPage()),
    GetPage(name: purchasedArtwork, page: () => const PurchasedArtworksPage()),
    GetPage(name: jobAuctionFair, page: () => const JobAuctionFairPage()),
  ];
}
