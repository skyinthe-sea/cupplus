import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final homeColors = Theme.of(context).extension<HomeColors>()!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: homeColors.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: homeColors.borderColor,
          ),
        ),
        child: Column(
          children: _buildChildren(homeColors),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(HomeColors homeColors) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          Padding(
            padding: EdgeInsets.only(left: 56.w),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: homeColors.borderColor,
            ),
          ),
        );
      }
    }
    return result;
  }
}
