import 'package:flutter/material.dart';

bool isAdmin =
    true; // Change this to the actual logic that determines if the user is an admin

// Define the navigation destinations based on user role
List<NavigationDestination> appBarDestinations = isAdmin
    ? [
        const NavigationDestination(
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
      ]
    : [
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
        )
      ];

//List de navigation a bar
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

//list de navigation
List<Widget> barWithBadgeDestinations = [
  NavigationDestination(
    tooltip: '',
    icon: Badge.count(count: 1000, child: const Icon(Icons.mail_outlined)),
    label: 'Mail',
    selectedIcon: Badge.count(count: 1000, child: const Icon(Icons.mail)),
  ),
  const NavigationDestination(
    tooltip: '',
    icon: Badge(label: Text('10'), child: Icon(Icons.chat_bubble_outline)),
    label: 'Chat',
    selectedIcon: Badge(label: Text('10'), child: Icon(Icons.chat_bubble)),
  ),
  const NavigationDestination(
    tooltip: '',
    icon: Badge(child: Icon(Icons.group_outlined)),
    label: 'Rooms',
    selectedIcon: Badge(child: Icon(Icons.group_rounded)),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Badge.count(count: 3, child: const Icon(Icons.videocam_outlined)),
    label: 'Meet',
    selectedIcon: Badge.count(count: 3, child: const Icon(Icons.videocam)),
  )
];
