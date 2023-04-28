import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/components/background.dart';
import 'package:project/entities/artist.dart';
import 'package:project/general/fonts.dart';
import 'package:project/general/themes.dart';
import 'package:project/general/utils.dart';
import 'package:project/pages/loading.dart';
import 'package:project/services/artwork_service.dart';
import '../../entities/artwork.dart';
import '../../entities/gallery.dart';
import '../../entities/user.dart';
import '../../services/artist_service.dart';
import '../../services/gallery_service.dart';
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
                  "Can we use your location to help with better recommendations?",
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
                "Can we use your location to help with better recommendations?",
                style: AppFonts.headerFont),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 300, vertical: 10),
              child: Row(
                children: [
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
            Text("Choose the artwork you prefer the most!",
                style: AppFonts.headerFont),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 100, vertical: 10),
              child: Row(
                children: [
                  for (var a in controller.artworks!)
                    Expanded(
                      child: GeneralCard(
                        name: a.title,
                        callback: controller.setFavArtwork,
                      ),
                    ),
                ],
              ),
            ),
            Text("Choose the Gallery you prefer the most!",
                style: AppFonts.headerFont),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
              child: Row(
                children: [
                  for (var g in controller.galleries!)
                    Expanded(
                      child: GeneralCard(
                        name: g.companyName,
                        callback: controller.setFavGallery,
                      ),
                    ),
                ],
              ),
            ),
            Text("Choose the Artist you prefer the most!",
                style: AppFonts.headerFont),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
              child: Row(
                children: [
                  for (var a in controller.aritsts!)
                    Expanded(
                      child: GeneralCard(
                        name: a.name,
                        callback: controller.setFavArtist,
                      ),
                    ),
                ],
              ),
            ),
            //Text("SKIP THIS: Purchased Artworks", style: AppFonts.headerFont),
            Row(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenSize.isMobile ? 5 : 70,
                          vertical: 10),
                      child: Text("What is Your profession?",
                          style: AppFonts.mediumFont),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenSize.isMobile ? 5 : 100,
                          vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 160,
                            child: RadioListTile<String?>(
                              title: const Text("Collector"),
                              value: "Collector",
                              groupValue: controller.jobGroupVal,
                              onChanged: (value) {
                                setState(() {
                                  if (value == "Collector") {
                                    controller.setIsVIP(false);
                                  }
                                  controller.jobGroupVal = value;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 160,
                            child: RadioListTile<String?>(
                              title: const Text("Journalist"),
                              value: "Journalist",
                              groupValue: controller.jobGroupVal,
                              onChanged: (value) {
                                setState(() {
                                  if (value == "Journalist") {
                                    controller.setIsVIP(true);
                                  }
                                  controller.jobGroupVal = value;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 160,
                            child: RadioListTile<String?>(
                              title: const Text("Curator"),
                              value: "Curator",
                              groupValue: controller.jobGroupVal,
                              onChanged: (value) {
                                setState(() {
                                  if (value == "Curator") {
                                    controller.setIsVIP(true);
                                  }
                                  controller.jobGroupVal = value;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 160,
                            child: RadioListTile<String?>(
                              title: const Text("Other"),
                              value: "Other",
                              groupValue: controller.jobGroupVal,
                              onChanged: (value) {
                                setState(() {
                                  if (value == "Other") {
                                    controller.setIsVIP(false);
                                  }
                                  controller.jobGroupVal = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenSize.isMobile ? 5 : 70,
                          vertical: 10),
                      child: Text("Do You got to Art Auctions?",
                          style: AppFonts.mediumFont),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenSize.isMobile ? 5 : 100,
                          vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 160,
                            child: RadioListTile<String?>(
                              title: const Text("Yes"),
                              value: "Yes",
                              groupValue: controller.auctionGroupVal,
                              onChanged: (value) {
                                setState(() {
                                  if (value == "Yes") {
                                    controller.setAuction(true);
                                  }
                                  controller.auctionGroupVal = value;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 160,
                            child: RadioListTile<String?>(
                              title: const Text("No"),
                              value: "No",
                              groupValue: controller.auctionGroupVal,
                              onChanged: (value) {
                                setState(() {
                                  if (value == "No") {
                                    controller.setAuction(false);
                                  }
                                  controller.auctionGroupVal = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenSize.isMobile ? 5 : 70,
                          vertical: 10),
                      child: Text("Do You got to Art Fairs?",
                          style: AppFonts.mediumFont),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenSize.isMobile ? 5 : 100,
                          vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 160,
                            child: RadioListTile<String?>(
                              title: const Text("Yes"),
                              value: "Yes",
                              groupValue: controller.fairGroupVal,
                              onChanged: (value) {
                                setState(() {
                                  if (value == "Yes") {
                                    controller.setFairs(true);
                                  }
                                  controller.fairGroupVal = value;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 160,
                            child: RadioListTile<String?>(
                              title: const Text("No"),
                              value: "No",
                              groupValue: controller.fairGroupVal,
                              onChanged: (value) {
                                setState(() {
                                  if (value == "No") {
                                    controller.setFairs(false);
                                  }
                                  controller.fairGroupVal = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                controller.bela.city = cityField.text;
                controller.bela.country = countryField.text;
                //print("Saving changes");
                //print(controller.bela);
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
}

class LocationController extends GetxController {
  List<Artwork>? artworks = [];
  List<Gallery>? galleries = [];
  List<Artist>? aritsts = [];
  final artworkService = ArtworkService();
  final galleryService = GalleryService();
  final artistService = ArtistService();

  User bela = User(
      id: '0',
      username: 'Béla',
      auctions: false,
      fairs: false,
      isVIP: false,
      country: 'Hungary');
  String? jobGroupVal = "Other";
  String? auctionGroupVal = "No";
  String? fairGroupVal = "No";

  load() async {
    artworks = await artworkService.getArtworks();
    galleries = await galleryService.getGalleries();
    aritsts = await artistService.getArtists();
    /*for (Artwork a in artworks!) {
      print(a.title);
    }
    print(" ");
    for (Gallery g in galleries!) {
      print(g.companyName);
    }
    print(" ");
    for (Artist a in aritsts!) {
      print(a.name);
    }*/
    update();
  }

  void setFavArtwork(String? s) {
    bela.favArtwork = s;
    print(bela.favArtwork);
  }

  void setFavGallery(String? s) {
    bela.favGallery = s;
    print(bela.favGallery);
  }

  void setFavArtist(String? s) {
    bela.favArtist = s;
    print(bela.favArtist);
  }

  void setIsVIP(bool s) {
    bela.isVIP = s;
    print("IsVIP: " + bela.isVIP.toString());
  }

  void setAuction(bool b) {
    bela.auctions = b;
    print("Auctions: " + bela.auctions.toString());
  }

  void setFairs(bool b) {
    bela.fairs = b;
    print("Fairs: " + bela.fairs.toString());
  }
}
