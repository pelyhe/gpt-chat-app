import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/components/background.dart';
import 'package:project/components/home/user_card.dart';
import 'package:project/entities/user.dart';
import 'package:project/general/fonts.dart';
import 'package:project/general/themes.dart';
import 'package:project/general/utils.dart';
import 'package:project/pages/loading.dart';
import 'package:project/services/user_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = HomeController();
  Future? loadUsers;

  @override
  void initState() {
    super.initState();
    loadUsers = controller.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.refresh(context);
    return FutureBuilder(
        future: loadUsers,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingPage();
          } else {
            return GetBuilder<HomeController>(
                init: controller,
                builder: (controller) {
                  return Scaffold(
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
    return Background(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Select user", style: AppFonts.headerFont),
              Row(
                children: [
                  const SizedBox(width: 50),
                  for (var u in controller.users!)
                    Expanded(child: UserCard(user: u)),
                  const SizedBox(width: 50),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _desktopBody() {
    return Background(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Select user", style: AppFonts.headerFont),
              Row(
                children: [
                  const SizedBox(width: 50),
                  for (var u in controller.users!)
                    Expanded(child: UserCard(user: u)),
                  const SizedBox(width: 50),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeController extends GetxController {
  List<User>? users = [];
  final userService = UserService();

  loadUsers() async {
    users = await userService.getUsers();
    update();
  }
}
