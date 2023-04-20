import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project/general/themes.dart';

class LoginScreenImage extends StatelessWidget {
  const LoginScreenImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "LOG IN",
          style: AppFonts.headerFont,
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: SvgPicture.asset("icons/login.svg"),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}