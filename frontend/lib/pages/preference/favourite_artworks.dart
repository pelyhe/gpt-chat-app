import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/components/background.dart';
import 'package:project/general/fonts.dart';
import 'package:project/general/themes.dart';
import 'package:project/general/utils.dart';
import 'package:project/pages/loading.dart';
import 'package:project/pages/preference/general_card.dart';

import '../../entities/user.dart';
import 'favourite_galleries.dart';

class FavouriteArtWorksPage extends StatefulWidget {
  const FavouriteArtWorksPage({Key? key}) : super(key: key);

  @override
  State<FavouriteArtWorksPage> createState() => _FavouriteArtWorksPageState();
}

class _FavouriteArtWorksPageState extends State<FavouriteArtWorksPage> {
  final controller = FavouriteArtWorksController();
  Future? load;

  @override
  void initState() {
    super.initState();
    load = controller.load();
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.refresh(context);
    return FutureBuilder(
        future: load,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingPage();
          } else {
            return GetBuilder<FavouriteArtWorksController>(
                init: controller,
                builder: (controller) {
                  return Scaffold(
                    body: scaffoldBody(
                      context: context,
                      //mobileBody: _mobileBody(),
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
              Text("Choose the artwork You like most!",
                  style: AppFonts.headerFont),
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
              Text("Choose the artwork You like the most!",
                  style: AppFonts.headerFont),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
                child: Row(
                  children: [
                    artworkCard(name: 'Artwork1'),
                    artworkCard(name: 'Artwork2'),
                    artworkCard(name: 'Artwork3'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/favouriteGallery');
                        },
                        child: Text(
                          "Next".toUpperCase(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Expanded artworkCard({required String name}) {
  return Expanded(
    child: GeneralCard(
      name: name,
      callback: () {},
    ),
  );
}

class FavouriteArtWorksController extends GetxController {
  load() async {
    update();
  }
}
