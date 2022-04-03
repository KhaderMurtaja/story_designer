import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GoBack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Icon(Icons.arrow_back, size: 28, color: Colors.white),
      onTap: () {
        if (Navigator.canPop(context)) Navigator.pop(context);
        SystemNavigator.pop();
      },
    );
  }
}
