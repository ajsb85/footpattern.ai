// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: use_build_context_synchronously

import 'package:employee_flutter/models/user_modal.dart';
import 'package:employee_flutter/services/attendance_service.dart';
import 'package:employee_flutter/services/auth_service.dart';
import 'package:employee_flutter/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:slide_to_act/slide_to_act.dart';


const rowDivider = SizedBox(width: 20);
const colDivider = SizedBox(height: 10);
const tinySpacing = 3.0;
const smallSpacing = 10.0;
const double widthConstraint = 450;
const double cardWidth = 115;
late final GraphQLClient graphQLClient;

class FirstComponentList extends StatelessWidget {
  const FirstComponentList({
    super.key,
    required this.showNavBottomBar,
    required this.scaffoldKey,
    required this.showSecondList,
  });

  final bool showNavBottomBar;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool showSecondList;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      const Actions(),
      colDivider,
    ];
    List<double?> heights = List.filled(children.length, null);

    // Fully traverse this list before moving on.
    return FocusTraversalGroup(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: showSecondList
                ? const EdgeInsetsDirectional.only(end: smallSpacing)
                : EdgeInsets.zero,
            sliver: SliverList(
              delegate: BuildSlivers(
                heights: heights,
                builder: (context, index) {
                  return _CacheHeight(
                    heights: heights,
                    index: index,
                    child: children[index],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SecondComponentList extends StatelessWidget {
  const SecondComponentList({
    super.key,
    required this.scaffoldKey,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      // Navigation(scaffoldKey: scaffoldKey),
      // colDivider,
      // const Selection(),
      // colDivider,
      // const TextInputs(),
    ];
    List<double?> heights = List.filled(children.length, null);

    // Fully traverse this list before moving on.
    return FocusTraversalGroup(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsetsDirectional.only(end: smallSpacing),
            sliver: SliverList(
              delegate: BuildSlivers(
                heights: heights,
                builder: (context, index) {
                  return _CacheHeight(
                    heights: heights,
                    index: index,
                    child: children[index],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// If the content of a CustomScrollView does not change, then it's
// safe to cache the heights of each item as they are laid out. The
// sum of the cached heights are returned by an override of
// `SliverChildDelegate.estimateMaxScrollOffset`. The default version
// of this method bases its estimate on the average height of the
// visible items. The override ensures that the scrollbar thumb's
// size, which depends on the max scroll offset, will shrink smoothly
// as the contents of the list are exposed for the first time, and
// then remain fixed.
class _CacheHeight extends SingleChildRenderObjectWidget {
  const _CacheHeight({
    super.child,
    required this.heights,
    required this.index,
  });

  final List<double?> heights;
  final int index;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderCacheHeight(
      heights: heights,
      index: index,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderCacheHeight renderObject) {
    renderObject
      ..heights = heights
      ..index = index;
  }
}

class _RenderCacheHeight extends RenderProxyBox {
  _RenderCacheHeight({
    required List<double?> heights,
    required int index,
  })  : _heights = heights,
        _index = index,
        super();

  List<double?> _heights;
  List<double?> get heights => _heights;
  set heights(List<double?> value) {
    if (value == _heights) {
      return;
    }
    _heights = value;
    markNeedsLayout();
  }

  int _index;
  int get index => _index;
  set index(int value) {
    if (value == index) {
      return;
    }
    _index = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    super.performLayout();
    heights[index] = size.height;
  }
}

// The heights information is used to override the `estimateMaxScrollOffset` and
// provide a more accurate estimation for the max scroll offset.
class BuildSlivers extends SliverChildBuilderDelegate {
  BuildSlivers({
    required NullableIndexedWidgetBuilder builder,
    required this.heights,
  }) : super(builder, childCount: heights.length);

  final List<double?> heights;

  @override
  double? estimateMaxScrollOffset(int firstIndex, int lastIndex,
      double leadingScrollOffset, double trailingScrollOffset) {
    return heights.reduce((sum, height) => (sum ?? 0) + (height ?? 0))!;
  }
}

class Actions extends StatelessWidget {
  const Actions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Buttons();
  }
}

//tetfskhch
class Buttons extends StatefulWidget {
  const Buttons({super.key});

  @override
  State<Buttons> createState() => _ButtonsState();
}

//tetfskhch
class _ButtonsState extends State<Buttons> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: ButtonsWithoutIcon(),
    );
  }
}

//me tetfskhch

class ButtonsWithoutIcon extends StatelessWidget {
  const ButtonsWithoutIcon({super.key});
  @override
  Widget build(BuildContext context) {
    final attendanceService = Provider.of<AttendanceService>(context);
    return Column(
      children: [
        Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 10),
            child: const Text("welcome",
                style: TextStyle(color: Colors.black54, fontSize: 30))),
        Consumer<DbService>(builder: (context, dbServie, child) {
          return FutureBuilder(
              future: dbServie.getUserData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  UserModel user = snapshot.data!;

                  return Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user.name != '' ? user.name : "#${user.employeeId}",
                      style: const TextStyle(fontSize: 25),
                    ),
                  );
                }
                return const SizedBox(
                  width: 60,
                  child: LinearProgressIndicator(),
                );
              });
        }),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 32),
          child: const Text(
            "Today's Status",
            style: TextStyle(fontSize: 20),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 32),
          height: 150,
          decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 2)),
              ],
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Check In",
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                    const SizedBox(
                      width: 80,
                      child: Divider(),
                    ),
                    Text(
                      attendanceService.attendanceModel?.checkIn ?? '--/--',
                      style: const TextStyle(fontSize: 25),
                    )
                  ],
                )),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Check Out",
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                    const SizedBox(
                      width: 80,
                      child: Divider(),
                    ),
                    Text(
                      attendanceService.attendanceModel?.checkOut ?? '--/--',
                      style: const TextStyle(fontSize: 25),
                    )
                  ],
                )),
              ]),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            DateFormat("dd MMMM yyyy").format(DateTime.now()),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat("hh:mm:ss a").format(DateTime.now()),
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
              );
            }),
        ElevatedButton(
          onPressed: () async {
            bool isAuthenticated = await AuthService.authenticateUser();
            if (isAuthenticated) {
              attendanceService.markAttendance(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Authentication failed.'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: Text(
            attendanceService.attendanceModel?.checkIn == null
                ? "Check In"
                : "Check Out",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }
}

//tetfskhch
class ButtonsWithIcon extends StatelessWidget {
  const ButtonsWithIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Icon'),
            ),
            colDivider,
            FilledButton.icon(
              onPressed: () {},
              label: const Text('Icon'),
              icon: const Icon(Icons.add),
            ),
            colDivider,
            FilledButton.tonalIcon(
              onPressed: () {},
              label: const Text('Icon'),
              icon: const Icon(Icons.add),
            ),
            colDivider,
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Icon'),
            ),
            colDivider,
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Icon'),
            )
          ],
        ),
      ),
    );
  }
}



  

