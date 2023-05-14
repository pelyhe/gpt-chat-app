import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/general/fonts.dart';
import 'package:project/general/themes.dart';

// ignore: must_be_immutable
class GeneralCard extends StatefulWidget {
  bool isHovering = false;
  String name;
  String pictureURL;
  Function callback;

  final hoveredTransform = Matrix4.identity()
    ..translate(-7, 4)
    ..scale(1.02);

  GeneralCard(
      {Key? key,
      required this.name,
      required this.callback,
      required this.pictureURL})
      : super(key: key);

  @override
  State<GeneralCard> createState() => _GeneralCardState();
}

class _GeneralCardState extends State<GeneralCard> {
  final controller = GeneralCardController();

  @override
  Widget build(BuildContext context) {
    final transform =
        widget.isHovering ? widget.hoveredTransform : Matrix4.identity();
    final elevation = widget.isHovering ? 50.0 : 10.0;

    return InkWell(
      onTap: () {
        widget.callback(widget.name);
        setState(() {
          controller.changeColor();
        });
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
        child: SizedBox(
          width: ScreenSize.width * 0.7 > 300 ? 300 : ScreenSize.width * 0.7,
          height: ScreenSize.width * 0.7 > 500 ? 500 : ScreenSize.width * 0.7,
          child: Card(
            elevation: elevation,
            color: controller.currentColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(widget.pictureURL),
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenSize.isMobile ? 5 : 20, vertical: 5),
                  child: Text(widget.name,
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
}

class GeneralCardController extends GetxController {
  Color currentColor = AppColors.kPrimaryLightColor;
  Color unselectedColor = AppColors.kPrimaryLightColor;
  Color selectedColor = AppColors.kPrimaryColor;

  changeColor() {
    if (currentColor == unselectedColor) {
      currentColor = selectedColor;
    } else if (currentColor == selectedColor) {
      currentColor = unselectedColor;
    }
  }
}
