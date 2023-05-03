import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../general/fonts.dart';
import '../../general/themes.dart';

class FeedbackPopup extends StatefulWidget {
  const FeedbackPopup({Key? key}) : super(key: key);

  @override
  State<FeedbackPopup> createState() => _FeedbackPopupState();
}

class _FeedbackPopupState extends State<FeedbackPopup> {
  final controller = Get.put(FeedbackPopupController());

  @override
  Widget build(BuildContext context) {
    ScreenSize.refresh(context);
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0)), //this right here
      child: SizedBox(
        height: ScreenSize.height * 0.7 > 400 ? 400 : ScreenSize.height * 0.7,
        width: ScreenSize.width * 0.7 > 700 ? 700 : ScreenSize.width * 0.7,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: InkWell(
                  onHover: (isHovering) {
                    if (isHovering) {
                      setState(() {
                        controller.isCustomerHovering = true;
                      });
                    } else {
                      setState(() {
                        controller.isCustomerHovering = false;
                      });
                    }
                  },
                  onTap: () =>
                      Navigator.pushNamed(context, '/register/customer'),
                  child: SizedBox.expand(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: controller.isCustomerHovering
                              ? AppColors.kPrimaryColor
                              : AppColors.kPrimaryColor.withAlpha(400)),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AppText("Register as customer",
                              style: GoogleFonts.mavenPro(
                                  fontSize: 30, color: Colors.black),
                              maxlines: 3),
                        ),
                      ),
                    ),
                  )),
            ),
            Expanded(
                child: InkWell(
              onHover: (isHovering) {
                if (isHovering) {
                  setState(() {
                    controller.isGalleryHovering = true;
                  });
                } else {
                  setState(() {
                    controller.isGalleryHovering = false;
                  });
                }
              },
              onTap: () => Navigator.pushNamed(context, '/register/gallery'),
              child: SizedBox.expand(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: controller.isGalleryHovering
                          ? AppColors.kPrimaryColor
                          : AppColors.kPrimaryColor.withAlpha(400)),
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AppText("Register as gallery",
                        style: GoogleFonts.mavenPro(
                            fontSize: 30,
                            color: controller.isGalleryHovering
                                ? Colors.white
                                : Colors.black),
                        maxlines: 3),
                  )),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class FeedbackPopupController extends GetxController {
  bool isCustomerHovering = false;
  bool isGalleryHovering = false;
}
