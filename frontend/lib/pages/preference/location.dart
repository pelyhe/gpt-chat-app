import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/components/background.dart';
import 'package:project/general/fonts.dart';
import 'package:project/general/themes.dart';
import 'package:project/general/utils.dart';
import 'package:project/pages/loading.dart';
import '../../entities/user.dart';
import 'favourite_artist.dart';
import 'favourite_artworks.dart';
import 'favourite_galleries.dart';
import 'general_card.dart';
import 'job_action_fairs.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final controller = LocationController();
  TextEditingController countryField = TextEditingController();
  TextEditingController cityField = TextEditingController();
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
            return GetBuilder<LocationController>(
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
              Text(
                  "Can we use Your location to help with better recommendations?",
                  style: AppFonts.headerFont),
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        //Save answer to db
                      },
                      child: Text(
                        "Yes".toUpperCase(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        //Save answer to db
                      },
                      child: Text(
                        "No".toUpperCase(),
                      ),
                    ),
                  ),
                ],
              )
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
            Text(
                "Can we use Your location to help with better recommendations?",
                style: AppFonts.headerFont),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 300, vertical: 10),
              child: Row(
                children: [
                  //TODO save these to DB
                  Expanded(
                    child: TextField(
                      controller: countryField,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Country',
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: cityField,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'City',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text("Choose the artwork You prefer the most!",
                style: AppFonts.headerFont),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
              child: Row(
                children: [
                  GeneralCard(
                    name: 'Artwork1',
                    callback: setFavArtwork,
                  ),
                  GeneralCard(
                    name: 'Artwork2',
                    callback: setFavArtwork,
                  ),
                  GeneralCard(
                    name: 'Artwork2',
                    callback: setFavArtwork,
                  ),
                ],
              ),
            ),
            Text("Choose the Gallery You prefer the most!",
                style: AppFonts.headerFont),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
              child: Row(
                children: [
                  GeneralCard(
                    name: 'Gallery1',
                    callback: setFavGallery,
                  ),
                  GeneralCard(
                    name: 'Gallery2',
                    callback: setFavGallery,
                  ),
                  GeneralCard(
                    name: 'Gallery3',
                    callback: setFavGallery,
                  ),
                ],
              ),
            ),
            Text("Choose the Artist You prefer the most!",
                style: AppFonts.headerFont),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
              child: Row(
                children: [
                  GeneralCard(
                    name: 'Artist1',
                    callback: setFavArtist,
                  ),
                  GeneralCard(
                    name: 'Artist2',
                    callback: setFavArtist,
                  ),
                  GeneralCard(
                    name: 'Artist3',
                    callback: setFavArtist,
                  ),
                ],
              ),
            ),
            Text("SKIP THIS: Purchased Artworks", style: AppFonts.headerFont),
            Text("What is Your profession?", style: AppFonts.headerFont),
            professionGroup(),
            Text("Do you go to Art Auctions?", style: AppFonts.headerFont),
            yesNoChoiseGroup(),
            Text("Do you go to Art Fairs?", style: AppFonts.headerFont),
            yesNoChoiseGroup(),
            ElevatedButton(
              onPressed: () {
                controller.bela.city = cityField.text;
                controller.bela.country = countryField.text;
                //Navigator.pushNamed(context, '/purchasedArtwork');
              },
              child: Text(
                "Save Preferences".toUpperCase(),
              ),
            ),
          ],
        ),
      )),
    );
  }

  void setFavArtwork(String s) {
    controller.bela.favArtwork = s;
    print(controller.bela.favArtwork);
  }

  void setFavGallery(String s) {
    controller.bela.favGallery = s;
    print(controller.bela.favGallery);
  }

  void setFavArtist(String s) {
    controller.bela.favArtist = s;
    print(controller.bela.favArtist);
  }
}

//GeneralCard Here

//RadioButton Here

class LocationController extends GetxController {
  User bela = User(id: '0', username: 'Béla');
  load() async {
    update();
  }
}
