import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/components/background.dart';
import 'package:project/general/fonts.dart';
import 'package:project/general/themes.dart';
import 'package:project/general/utils.dart';
import 'package:project/pages/loading.dart';

import 'favourite_artist.dart';
import 'general_card.dart';


class FavouriteGalleriesPage extends StatefulWidget {
  const FavouriteGalleriesPage({Key? key}) : super(key: key);

  @override
  State<FavouriteGalleriesPage> createState() => _FavouriteGalleriesPageState();
}

class _FavouriteGalleriesPageState extends State<FavouriteGalleriesPage> {
  final controller = FavouriteGalleriesController();
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
            return GetBuilder<FavouriteGalleriesController>(
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
              Text("Choose the artwork You like most",
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
                    galleryCard(name: 'Gallery1'),
                    galleryCard(name: 'Gallery2'),
                    galleryCard(name: 'Gallery3'),
                  ],
                ),
              ),Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          //TODO Save answer to db
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const FavouriteArtistPage()),
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

Expanded galleryCard({required String name}) {
  return Expanded(
    child: GeneralCard(
      name: name,
    ),
  );
}

class FavouriteGalleriesController extends GetxController {
  load() async {
    update();
  }
}
