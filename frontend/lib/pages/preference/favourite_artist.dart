import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/components/background.dart';
import 'package:project/general/fonts.dart';
import 'package:project/general/themes.dart';
import 'package:project/general/utils.dart';
import 'package:project/pages/loading.dart';

import 'bought_artworks.dart';


class FavouriteArtistPage extends StatefulWidget {
  const FavouriteArtistPage({Key? key}) : super(key: key);

  @override
  State<FavouriteArtistPage> createState() => _FavouriteArtistPageState();
}

class _FavouriteArtistPageState extends State<FavouriteArtistPage> {
  final controller = FavouriteArtistController();
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
            return GetBuilder<FavouriteArtistController>(
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
              Text("Choose the artist You like most!",
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
              Text("Choose the Gallery You like the most!",
                  style: AppFonts.headerFont),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          //Save answer to db
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BoughtArtworksPage()),
                          );
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

class FavouriteArtistController extends GetxController {
  load() async {
    update();
  }
}
