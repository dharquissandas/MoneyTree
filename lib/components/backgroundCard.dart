import 'package:flutter/material.dart';

class BackgroundCard extends StatelessWidget {
  final int height;
  final Widget child;

  const BackgroundCard({Key key, this.height, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
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
