import 'package:employee_flutter/screens/NavigationBar/ComponentDec_Screen.dart';
import 'package:employee_flutter/screens/NavigationBar/constant.dart';
import 'package:employee_flutter/services/db_service.dart';
import 'package:flutter/material.dart';

DbService dbService = DbService();
Future<bool> isAdmin() async {
  final admin = await dbService.checkAdminStatus();
  return admin; // Assuming 'true' means admin and 'false' means non-admin
}

class NavigationBars extends StatefulWidget {
  const NavigationBars({
    Key? key,
    this.onSelectItem,
    required this.selectedIndex,
    required this.isExampleBar,
    this.isBadgeExample = false,
  }) : super(key: key);

  final void Function(int)? onSelectItem;
  final int selectedIndex;
  final bool isExampleBar;
  final bool isBadgeExample;

  @override
  State<NavigationBars> createState() => _NavigationBarsState();
}

class _NavigationBarsState extends State<NavigationBars> {
  int selectedIndex = 0; // Initialize with a default value
  List<NavigationDestination> appBarDestinations = [];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    initializeDestinations();
  }

  void initializeDestinations() async {
    final admin = await isAdmin();
    setState(() {
      appBarDestinations = admin
          ? [
              NavigationDestination(
                tooltip: '',
                icon: Icon(Icons.person_4),
                label: 'Users',
                selectedIcon: Icon(Icons.person_4_outlined),
              ),
              NavigationDestination(
                tooltip: '',
                icon: Icon(Icons.bluetooth),
                label: 'Devices',
                selectedIcon: Icon(Icons.bluetooth_outlined),
              ),
              NavigationDestination(
                tooltip: '',
                icon: Icon(Icons.calendar_month),
                label: 'Attendances',
                selectedIcon: Icon(Icons.calendar_month_outlined),
              ),
            ]
          : [
              NavigationDestination(
                tooltip: '',
                icon: Icon(Icons.calendar_month),
                label: 'Calendar',
                selectedIcon: Icon(Icons.calendar_month_outlined),
              ),
              NavigationDestination(
                tooltip: '',
                icon: Icon(Icons.check),
                label: 'Check',
                selectedIcon: Icon(Icons.check_outlined),
              ),
              NavigationDestination(
                tooltip: '',
                icon: Icon(Icons.person_2),
                label: 'Profile',
                selectedIcon: Icon(Icons.person_2_outlined),
              ),
            ];

      if (appBarDestinations.length < 2) {
        // Ensure there are at least two destinations
        appBarDestinations.add(NavigationDestination(
          tooltip: '',
          icon: Icon(Icons.error),
          label: 'Error',
          selectedIcon: Icon(Icons.error_outline),
        ));
      }
    });
  }

  @override
  void didUpdateWidget(covariant NavigationBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex &&
        widget.selectedIndex >= 0 &&
        widget.selectedIndex < appBarDestinations.length) {
      setState(() {
        selectedIndex = widget.selectedIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget navigationBar = Focus(
      autofocus: !(widget.isExampleBar || widget.isBadgeExample),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
          if (!widget.isExampleBar) widget.onSelectItem!(index);
        },
        destinations: widget.isExampleBar && widget.isBadgeExample
            ? barWithBadgeDestinations
            : widget.isExampleBar
                ? exampleBarDestinations
                : appBarDestinations,
      ),
    );

    if (widget.isExampleBar && widget.isBadgeExample) {
      navigationBar = ComponentDecoration(
          label: 'Badges',
          tooltipMessage: 'Use Badge or Badge.count',
          child: navigationBar);
    } else if (widget.isExampleBar) {
      navigationBar = ComponentDecoration(
          label: 'Navigation bar',
          tooltipMessage: 'Use NavigationBar',
          child: navigationBar);
    }

    return navigationBar;
  }
}

const List<Widget> exampleBarDestinations = [
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.explore_outlined),
    label: 'Explore',
    selectedIcon: Icon(Icons.explore),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.pets_outlined),
    label: 'Pets',
    selectedIcon: Icon(Icons.pets),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.account_box_outlined),
    label: 'Account',
    selectedIcon: Icon(Icons.account_box),
  )
];

List<Widget> barWithBadgeDestinations = [
  NavigationDestination(
    tooltip: '',
    icon: Badge.count(count: 1000, child: Icon(Icons.mail_outlined)),
    label: 'Mail',
    selectedIcon: Badge.count(count: 1000, child: Icon(Icons.mail)),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Badge(label: Text('10'), child: Icon(Icons.chat_bubble_outline)),
    label: 'Chat',
    selectedIcon: Badge(label: Text('10'), child: Icon(Icons.chat_bubble)),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Badge(child: Icon(Icons.group_outlined)),
    label: 'Rooms',
    selectedIcon: Badge(child: Icon(Icons.group_rounded)),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Badge.count(count: 3, child: Icon(Icons.videocam_outlined)),
    label: 'Meet',
    selectedIcon: Badge.count(count: 3, child: Icon(Icons.videocam)),
  ),
];
