import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Heading extends StatelessWidget {
  final String title;
  final double fontSize;
  final Widget child;
  final EdgeInsets padding;

  const Heading({Key key, this.fontSize, this.title, this.child, this.padding})
      : super(key: key);

  // Build Heading
  @override
  Widget build(BuildContext context) {
    if (this.child == null) {
      return Padding(
        padding: this.padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(this.title,
                style: GoogleFonts.inter(
                    fontSize: this.fontSize,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3A3A3A))),
          ],
        ),
      );
    } else {
      return Padding(
        padding: this.padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(this.title,
                style: GoogleFonts.inter(
                    fontSize: this.fontSize,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3A3A3A))),
            this.child,
          ],
        ),
      );
    }
  }
}
