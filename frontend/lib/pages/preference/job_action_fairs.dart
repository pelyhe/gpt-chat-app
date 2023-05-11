import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/components/background.dart';
import 'package:project/general/fonts.dart';
import 'package:project/general/themes.dart';
import 'package:project/general/utils.dart';
import 'package:project/pages/loading.dart';

//TODO Merge Job and Auction and Fairs
class JobAuctionFairPage extends StatefulWidget {
  const JobAuctionFairPage({Key? key}) : super(key: key);

  @override
  State<JobAuctionFairPage> createState() => _JobAuctionFairPageState();
}

class _JobAuctionFairPageState extends State<JobAuctionFairPage> {
  final controller = JobAuctionFairController();
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
            return GetBuilder<JobAuctionFairController>(
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
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
                child: Text("What is Your profession?",
                    style: AppFonts.headerFont),
              ),
              professionGroup(),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
                child: Text("Do you go to Art Auctions?",
                    style: AppFonts.headerFont),
              ),
              yesNoChoiseGroup(),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
                child:
                    Text("Do you go to Art Fairs?", style: AppFonts.headerFont),
              ),
              yesNoChoiseGroup(),
            ],
          ),
        ),
      ),
    );
  }
}

Padding professionGroup() {
  String? answer;
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
    child: Row(
      children: [
        Expanded(
          child: RadioListTile(
            title: const Text("Collector"),
            value: "Collector",
            groupValue: answer,
            onChanged: (value) {
              answer = value.toString();
            },
          ),
        ),
        Expanded(
          child: RadioListTile(
            title: const Text("Journalist"),
            value: "Journalist",
            groupValue: answer,
            onChanged: (value) {
              answer = value.toString();
            },
          ),
        ),
        Expanded(
          child: RadioListTile(
            title: const Text("Curator"),
            value: "Curator",
            groupValue: answer,
            onChanged: (value) {
              answer = value.toString();
            },
          ),
        ),
        Expanded(
          child: RadioListTile(
            title: const Text("User"),
            value: "User",
            groupValue: answer,
            onChanged: (value) {
              answer = value.toString();
            },
          ),
        ),
      ],
    ),
  );
}

Padding yesNoChoiseGroup() {
  String? answer;
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
    child: Row(
      children: [
        Expanded(
          child: RadioListTile(
            title: const Text("Yes"),
            value: "Yes",
            groupValue: answer,
            onChanged: (value) {
              answer = value.toString();
            },
          ),
        ),
        Expanded(
          child: RadioListTile(
            title: const Text("No"),
            value: "No",
            groupValue: answer,
            onChanged: (value) {
              answer = value.toString();
            },
          ),
        ),
      ],
    ),
  );
}

class JobAuctionFairController extends GetxController {
  load() async {
    update();
  }
}
