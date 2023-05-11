import 'package:flutter/material.dart';

import 'package:project/entities/user.dart';
import 'package:project/general/fonts.dart';
import 'package:project/general/themes.dart';
import 'package:project/general/utils.dart';

// ignore: must_be_immutable
class UserCard extends StatefulWidget {
  User user;
  bool isHovering = false;
  final hoveredTransform = Matrix4.identity()
    ..translate(-7, 4)
    ..scale(1.02);

  UserCard({Key? key, required this.user}) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    final transform =
        widget.isHovering ? widget.hoveredTransform : Matrix4.identity();
    final elevation = widget.isHovering ? 50.0 : 10.0;

    return SizedBox(
      width: ScreenSize.width * 0.7 > 300 ? 300 : ScreenSize.width * 0.7,
      height: ScreenSize.width * 0.7 > 500 ? 500 : ScreenSize.width * 0.7,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/chat?id=${widget.user.id}');
        },
        onHover: (isHovering) {
          if (isHovering) {
            if (mounted) {
              setState(() {
                widget.isHovering = true;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                widget.isHovering = false;
              });
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: transform,
          child: Card(
            elevation: elevation,
            color: AppColors.kPrimaryLightColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: CircleAvatar(
                    radius: ScreenSize.isDesktop
                        ? // responsive size
                        85
                        : ScreenSize.isTablet
                            ? 65
                            : 30,
                    backgroundColor: AppColors.kPrimaryColor,
                    child: ScreenSize.isDesktop
                        ? createAvatarFromName(80, _getUsername(widget.user), 0)
                        : ScreenSize.isTablet
                            ? createAvatarFromName(60, _getUsername(widget.user), 0)
                            : createAvatarFromName(40, _getUsername(widget.user), 0),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenSize.isMobile ? 5 : 20, vertical: 5),
                  child: Text(widget.user.username,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenSize.isMobile ? 15 : 30,
                      ),
                      maxLines: 2),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getUsername(User user) {
    List<String> username = user.username.split(' ');
    if (username.length > 1) {
      String secondName = username[1];
      while (secondName.startsWith(RegExp('^[^a-zA-Z0-9]'))) {
        secondName = secondName.substring(1);
      }
      return username[0] + ' ' + secondName;
    } else {
      return username[0];
    }
  }
}
