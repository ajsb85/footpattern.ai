import 'package:employee_flutter/screens/NavigationBar/ComponentDec_Screen.dart';
import 'package:employee_flutter/screens/NavigationBar/NavigationSection_Screen.dart';
import 'package:flutter/material.dart';

class NavigationRails extends StatelessWidget {
  const NavigationRails({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentDecoration(
      label: 'Navigation rail',
      tooltipMessage: 'Use NavigationRail',
      child: IntrinsicWidth(
          child: SizedBox(height: 420, child: NavigationRailSection())),
    );
  }
}
