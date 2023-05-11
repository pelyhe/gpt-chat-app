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
import 'package:project/entities/artwork.dart';
import 'package:project/entities/gallery.dart';
import 'package:project/entities/user.dart';
import 'package:project/services/artist_service.dart';
import 'package:project/services/gallery_service.dart';
import 'general_card.dart';

class LocationPage extends StatefulWidget {
  static String idParameterName = "userid";
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
    controller.userid = Get.parameters[LocationPage.idParameterName]!;
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
                      mobileBody: _mobileBody(),
                      tabletBody: _mobileBody(),
                      desktopBody: _desktopBody(),
                    ),
                  );
                });
          }
        });
  }

  //                     width: ScreenSize.width * 0.9 > 2*300+10 ? 300 : ScreenSize.width * 0.9 / 2 - 10,
  Widget _mobileBody() {
    return Background(
      child: SingleChildScrollView(
          child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                      "Can we use your location to help with better recommendations?",
                      style: AppFonts.headerFont),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      // 2 * 300 = textbox width, +30 = 10*2 (horizontal column padding) + 10 (space between fields)
                      width: ScreenSize.width * 0.9 > 2*300+30 ? 300 : ScreenSize.width * 0.9 / 2 - 30,
                      child: TextField(
                        controller: countryField,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Country',
                            fillColor: AppColors.grey!),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: ScreenSize.width * 0.9 > 2*300+10 ? 300 : ScreenSize.width * 0.9 / 2 - 10,
                      child: TextField(
                        controller: cityField,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'City',
                            fillColor: AppColors.grey!),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text("Which artwork you prefer the most?",
                  style: AppFonts.headerFont),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Wrap(
                  runSpacing: 15,
                  spacing: 15,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var a in controller.artworks!)
                      GeneralCard(
                        name: a.title,
                        callback: controller.setFavArtwork,
                        pictureURL: controller.setURL(a.title),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text("Which gallery you prefer the most?",
                  style: AppFonts.headerFont),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Wrap(
                  runSpacing: 15,
                  spacing: 15,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var g in controller.galleries!)
                      GeneralCard(
                        name: g.name,
                        callback: controller.setFavGallery,
                        pictureURL: controller.setURL(g.name),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text("Which artist you prefer the most?",
                  style: AppFonts.headerFont),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Wrap(
                  runSpacing: 15,
                  spacing: 15,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var a in controller.artists!)
                      GeneralCard(
                        name: a.name,
                        callback: controller.setFavArtist,
                        pictureURL: controller.setURL(a.name),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                runSpacing: 15,
                spacing: 15,
                alignment: WrapAlignment.center,
                children: [
                  jobCol(),
                  artfairCol(),
                  artAuctionCol(),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenSize.width /4, vertical: 30 ),
                child: saveBtn())
            ],
          ),
        ),
      )),
    );
  }

  Widget _desktopBody() {
    return Background(
      child: SingleChildScrollView(
          child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                      "Can we use your location to help with better recommendations?",
                      style: AppFonts.headerFont),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: countryField,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Country',
                            fillColor: AppColors.grey!),
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: cityField,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'City',
                            fillColor: AppColors.grey!),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text("Which artwork you prefer the most?",
                  style: AppFonts.headerFont),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Wrap(
                  runSpacing: 15,
                  spacing: 15,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var a in controller.artworks!)
                      GeneralCard(
                        name: a.title,
                        callback: controller.setFavArtwork,
                        pictureURL: controller.setURL(a.title),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text("Which gallery you prefer the most?",
                  style: AppFonts.headerFont),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Wrap(
                  runSpacing: 15,
                  spacing: 15,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var g in controller.galleries!)
                      GeneralCard(
                        name: g.name,
                        callback: controller.setFavGallery,
                        pictureURL: controller.setURL(g.name),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text("Which artist you prefer the most?",
                  style: AppFonts.headerFont),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Wrap(
                  runSpacing: 15,
                  spacing: 15,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var a in controller.artists!)
                      GeneralCard(
                        name: a.name,
                        callback: controller.setFavArtist,
                        pictureURL: controller.setURL(a.name),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                runSpacing: 15,
                spacing: 15,
                alignment: WrapAlignment.center,
                children: [
                  jobCol(),
                  artfairCol(),
                  artAuctionCol(),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenSize.width /4, vertical: 30 ),
                child: saveBtn())
            ],
          ),
        ),
      )),
    );
  }

  Widget jobCol() {
    return SizedBox(
      width: 160,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("What is your profession?", style: AppFonts.mediumFont),
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
    );
  }

  Widget artfairCol() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Do you got to art auctions?", style: AppFonts.mediumFont),
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
    );
  }

  Widget artAuctionCol() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Do you got to art fairs?", style: AppFonts.mediumFont),
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
    );
  }

  Widget saveBtn() {
    return ElevatedButton(
      onPressed: () {
        controller.currentUser.city = cityField.text;
        controller.currentUser.country = countryField.text;
        controller.userService.updateUser(controller.currentUser);
      },
      child: Text(
        "Save Preferences".toUpperCase(),
      ),
    );
  }
}

class LocationController extends GetxController {
  late String userid;
  List<User>? users = [];
  late User currentUser;
  List<Artwork>? artworks = [];
  List<Gallery>? galleries = [];
  List<Artist>? artists = [];
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
    artists = await artistService.getArtists();
    for (User u in users!) {
      if (u.id == userid) {
        currentUser = u;
      }
    }
    update();
  }

  setURL(String title) {
    if (title == "Bond Street I") {
      return 'assets/images/bond_street_I_picture.png';
    }
    if (title == "Mile End") {
      return 'assets/images/mile_end_picture.png';
    }
    if (title == "Brompton Road") {
      return 'assets/images/brompton_road_picture.png';
    }
    if (title == "Costumier") {
      return 'assets/images/costumier.png';
    }
    if (title == "Hatton Garden") {
      return 'assets/images/hatton_garden.png';
    }
    if (title == "New Bond St") {
      return 'assets/images/new_bond_st.png';
    }

    if (title == "Koller Gallery") {
      return 'assets/images/koller_gallery.jpg';
    }
    if (title == "Misa Art") {
      return 'assets/images/misa_art_gallery.jpg';
    }
    if (title == "The British Museum") {
      return 'assets/images/british_museum_gallery.jpg';
    }
    if (title == "Glassyard Gallery") {
      return 'assets/images/glassyard_gallery.png';
    }

    if (title == "Julian Rosefeldt") {
      return 'assets/images/julian_rosefeldt.png';
    }
    if (title == "Paul Herrmann") {
      return 'assets/images/no_image.png';
    }
    if (title == "William Anthony") {
      return 'assets/images/no_image.png';
    }
    if (title == "Jule Waibel") {
      return 'assets/images/jule_waibel.png';
    }
    if (title == "Sarah Dobai") {
      return 'assets/images/sarah_dobai.png';
    }

    return 'assets/images/no_image.png';
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

  void setIsVIP(bool b) {
    currentUser.isVIP = b;
  }

  void setAuction(bool b) {
    currentUser.auctions = b;
  }

  void setFairs(bool b) {
    currentUser.fairs = b;
  }
}
