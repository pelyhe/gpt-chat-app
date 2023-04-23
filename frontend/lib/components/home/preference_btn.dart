import 'package:flutter/material.dart';

import '../../pages/preference/location.dart';

class PreferenceBtn extends StatelessWidget {
  const PreferenceBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: "Take Preferences Quiz",
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LocationPage()),
              );
            },
            child: Text(
              "Take Preferences Quiz".toUpperCase(),
            ),
          ),
        ),
      ],
    );
  }
}
