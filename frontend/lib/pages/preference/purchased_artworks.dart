import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/components/background.dart';
import 'package:project/general/fonts.dart';
import 'package:project/general/themes.dart';
import 'package:project/general/utils.dart';
import 'package:project/pages/loading.dart';
import 'job_action_fairs.dart';

class PurchasedArtworksPage extends StatefulWidget {
  const PurchasedArtworksPage({Key? key}) : super(key: key);

  @override
  State<PurchasedArtworksPage> createState() => _PurchasedArtworksPageState();
}

class _PurchasedArtworksPageState extends State<PurchasedArtworksPage> {
  final controller = PurchasedArtworksController();
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
            return GetBuilder<PurchasedArtworksController>(
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
              Text("SKIP THIS", style: AppFonts.headerFont),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenSize.isMobile ? 5 : 400, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/jobAuctionFair');
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

class PurchasedArtworksController extends GetxController {
  load() async {
    update();
  }
}
