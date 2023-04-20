import 'package:avatars/avatars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/general/fonts.dart';
import 'package:project/general/themes.dart';

//depending on what kind of screen will your app run, you can just comment the unnecessary lines
Widget scaffoldBody(
    {required BuildContext context,
    Widget? mobileBody,
    Widget? tabletBody,
    Widget? desktopBody}) {
  ScreenSize.refresh(context);

  if (ScreenSize.isMobile) {
    return mobileBody!;
  } else if (ScreenSize.isTablet) {
    return tabletBody!;
  } else {
    return desktopBody!;
  }
}

createAvatarFromName(double radius, String name, int notifications) {
  return SizedBox(
    width: radius * 2,
    child: Stack(alignment: Alignment.bottomLeft, children: [
      Avatar(
          placeholderColors: [AppColors.kPrimaryColor],
          name: name,
          shape: AvatarShape.circle(radius)),
      if (notifications != 0)
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            width: radius > 30 ? 30 : radius,
            height: radius > 30 ? 30 : radius,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 0.5,
              ),
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              notifications.toString(),
              style: TextStyle(
                fontSize: radius / 2 > 18 ? 18 : radius / 2,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        )
    ]),
  );
}
