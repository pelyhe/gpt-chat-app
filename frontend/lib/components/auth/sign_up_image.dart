import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project/general/themes.dart';

class SignUpScreenImage extends StatelessWidget {
  const SignUpScreenImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Sign Up".toUpperCase(),
          style: AppFonts.headerFont,
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: SvgPicture.asset("icons/signup.svg"),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
