import 'package:flutter/material.dart';
import 'package:whatsapp/utils/appColors.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.initials,
    this.radius = 22,
    this.highlight = false,
  });

  final String initials;
  final double radius;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(highlight ? 2 : 0),
      decoration: highlight
          ? BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.lightPrimary, AppColors.primary],
              ),
            )
          : null,
      child: SizedBox(
        height: radius * 2,
        width: radius * 2,
        child: CircleAvatar(
          backgroundColor: Colors.grey.shade300,
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
