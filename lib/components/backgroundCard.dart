import 'package:flutter/material.dart';

class BackgroundCard extends StatelessWidget {
  final double height;
  final Widget child;
  final bool clickable;

  const BackgroundCard({Key key, this.height, this.clickable, this.child})
      : super(key: key);

// Display Generic White Card
  @override
  Widget build(BuildContext context) {
    return Container(
        height: this.height,
        margin: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(0, 2.0))
          ],
        ),
        child: this.child);
  }
}
