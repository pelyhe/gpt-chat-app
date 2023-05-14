import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/components/background.dart';
import 'package:project/entities/artist.dart';
import 'package:project/general/fonts.dart';
import 'package:project/general/themes.dart';
import 'package:project/general/utils.dart';
import 'package:project/pages/loading.dart';
import 'package:project/services/artwork_service.dart';
import 'package:project/services/user_service.dart';
import '../entities/artwork.dart';
import '../entities/gallery.dart';
import '../entities/user.dart';
import '../services/artist_service.dart';
import '../services/gallery_service.dart';
import '../components/chat/general_card.dart';

class PreferenceQuizPage extends StatefulWidget {
  static String idParameterName = "userid";
  const PreferenceQuizPage({Key? key}) : super(key: key);

  @override
  State<PreferenceQuizPage> createState() => _PreferenceQuizPageState();
}

class _PreferenceQuizPageState extends State<PreferenceQuizPage> {
  final controller = LocationController();
  TextEditingController countryField = TextEditingController();
  TextEditingController cityField = TextEditingController();
  Future? load;

  @override
  void initState() {
    super.initState();
    controller.userid = Get.parameters[PreferenceQuizPage.idParameterName]!;
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
            SizedBox(width: ScreenSize.width, height: ScreenSize.height * 0.05),
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Country',
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: cityField,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'City',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: ScreenSize.width, height: ScreenSize.height * 0.05),
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
                        pictureURL: controller.setURL(a.title),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: ScreenSize.width, height: ScreenSize.height * 0.05),
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
                        name: g.name,
                        callback: controller.setFavGallery,
                        pictureURL: controller.setURL(g.name),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: ScreenSize.width, height: ScreenSize.height * 0.05),
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
                        pictureURL: controller.setURL(a.name),
                      ),
                    ),
                ],
              ),
            ),
            //Text("SKIP THIS: Purchased Artworks", style: AppFonts.headerFont),
            SizedBox(width: ScreenSize.width, height: ScreenSize.height * 0.05),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.width * 0.27,
                  vertical: 0),
              child: Row(
                children: [
                  jobCol(),
                  SizedBox(width: ScreenSize.width*0.01, height: ScreenSize.height * 0.05),
                  artfairCol(),
                  SizedBox(width: ScreenSize.width*0.01, height: ScreenSize.height * 0.05),
                  artAuctionCol(),
                ],
              ),
            ),
            SizedBox(width: ScreenSize.width, height: ScreenSize.height * 0.03),
            saveBtn(),
            SizedBox(width: ScreenSize.width, height: ScreenSize.height * 0.03),
          ],
        ),
      )),
    );
  }

  Widget jobCol() {
    return Column(
      children: [
        Text("What is your profession?", style: AppFonts.mediumFont),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
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
            SizedBox(
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
            SizedBox(
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
            SizedBox(
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
      ],
    );
  }

  Widget artfairCol() {
    return Column(
      children: [
        Text("Do you got to Art Auctions?", style: AppFonts.mediumFont),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
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
            SizedBox(
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
      ],
    );
  }

  Widget artAuctionCol() {
    return Column(
      children: [
        Text("Do you got to Art Fairs?", style: AppFonts.mediumFont),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
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
            SizedBox(
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
      ],
    );
  }

  Widget saveBtn() {
    return Row(
      children: [
        SizedBox(
            width: ScreenSize.width * 0.3, height: ScreenSize.height * 0.03),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              controller.currentUser.city = cityField.text;
              controller.currentUser.country = countryField.text;
              controller.userService.updateUser(controller.currentUser);
              //print(controller.currentUser);
              //Navigator.pushNamed(context, '/purchasedArtwork');
            },
            child: Text(
              "Save Preferences".toUpperCase(),
            ),
          ),
        ),
        SizedBox(
            width: ScreenSize.width * 0.3, height: ScreenSize.height * 0.03),
      ],
    );
  }
}

class LocationController extends GetxController {
  late String userid;
  List<User>? users = [];
  late User currentUser;
  List<Artwork>? artworks = [];
  List<Gallery>? galleries = [];
  List<Artist>? aritsts = [];
  final userService = UserService();
  final artworkService = ArtworkService();
  final galleryService = GalleryService();
  final artistService = ArtistService();
  String? jobGroupVal = "Other";
  String? auctionGroupVal = "No";
  String? fairGroupVal = "No";

  load() async {
    users = await userService.getUsers();
    artworks = await artworkService.getArtworks();
    galleries = await galleryService.getGalleries();
    aritsts = await artistService.getArtists();
    for (User u in users!) {
      if (u.id == userid) {
        currentUser = u;
      }
    }
    update();
  }

  setURL(String title) {
    if (title == "Bond Street I") {
      return 'images/bond_street_I_picture.png';
    }
    if (title == "Mile End") {
      return 'images/mile_end_picture.png';
    }
    if (title == "Brompton Road") {
      return 'images/brompton_road_picture.png';
    }
    if (title == "Costumier") {
      return 'images/costumier.png';
    }
    if (title == "Hatton Garden") {
      return 'images/hatton_garden.png';
    }
    if (title == "New Bond St") {
      return 'images/new_bond_st.png';
    }

    if (title == "Koller Gallery") {
      return 'images/koller_gallery.jpg';
    }
    if (title == "Misa Art") {
      return 'images/misa_art_gallery.jpg';
    }
    if (title == "The British Museum") {
      return 'images/british_museum_gallery.jpg';
    }
    if (title == "Glassyard Gallery") {
      return 'images/glassyard_gallery.png';
    }

    if (title == "Julian Rosefeldt") {
      return 'images/julian_rosefeldt.png';
    }
    if (title == "Paul Herrmann") {
      return 'images/no_image.png';
    }
    if (title == "William Anthony") {
      return 'images/no_image.png';
    }
    if (title == "Jule Waibel") {
      return 'images/jule_waibel.png';
    }
    if (title == "Sarah Dobai") {
      return 'images/sarah_dobai.png';
    }



    return 'images/no_image.png';
  }

  void setFavArtwork(String s) {
    currentUser.favArtwork = s;
  }

  void setFavGallery(String s) {
    currentUser.favGallery = s;
  }

  void setFavArtist(String s) {
    currentUser.favArtist = s;
  }

  void setIsVIP(bool s) {
    currentUser.isVIP = s;
  }

  void setAuction(bool b) {
    currentUser.auctions = b;
  }

  void setFairs(bool b) {
    currentUser.fairs = b;
  }
}
