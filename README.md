# Treeed for Flutter.

[Treeed](https://github.com/marat0n/treeed) is a simple, fast, architecture-agnostic and lightweight state-manager for Dart. This package is a specific wrapper of the Treeed, made just for Flutter projects.

## Overview

This package contains one main component: TreeedObservable widget. Use it for reactive changes in your project.

Short guide:
1. For simple updates use `TreeedObservable`.
2. For animated updates use `TreeedAnimatedObservable`.

### Example.

`state.dart` file (defining the state here):
```dart
import 'package:treeed/treeed.dart';

// Root state of the app.
class MyState extends TreeedGroup {
  late final counter = treeedState(0);
  late final subGroup = treeedGroup(MySubState());
  late final tabsState = treeedGroup(TabsState());
}

// Some sub-state with user's data.
class MySubState extends TreeedGroup {
  late final userName = treeedState('');
  late final userAge = treeedState(0);
}

// Model of app's tabs.
enum PageTab {
  main,
  settings;

  bool get shouldShowNavBar => this == main;
  bool get shouldShowBackButton => this == settings;
}

// State container for tabs state.
class TabsState extends TreeedGroup {
  late final tab = treeedState(PageTab.main);
}
```

`main.dart` file (building app and using state here):
```dart
import 'package:flutter/material.dart';
import 'package:treeed_flutter/treeed_flutter.dart';
import 'state.dart';

void main() {
  runApp(MyApp(state: MyState())); // Sending instance of app's state in DI-way.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.state});

  final MyState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(

        // Animated changing of the tab.
        body: TreeedAnimatedObservable(
          changingDuration: Durations.short4,
          transitionBuilder: (child, animation) => SlideTransition(
            position: animation.drive(
              Tween(
                begin: Offset(1, 0.2),
                end: Offset(0, 0),
              ).chain(CurveTween(curve: Curves.easeOut)),
            ),
            child: child,
          ),
          stateToWatch: state.tabsState,
          builder: (context) => switch (state.tabsState.tab.get) {
            PageTab.main => MainPage(state: state),
            PageTab.settings => SettingsPage(),
          },
        ),

        // Appbar widget `MyAppBar` working with state by itself.
        appBar: MyAppBar(state: state),
        
        // navigation bar widget here is set based on the state.
        bottomNavigationBar: TreeedObservable(
          stateToWatch: state.tabsState.tab,
          builder: (_) => switch (state.tabsState.tab.get.shouldShowNavBar) {
            true => NavBar(state: state),
            _ => SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.state});
  final MyState state;

  @override
  Widget build(BuildContext context) {
    return TreeedObservable(
      stateToWatch: state.tabsState.tab,

      // Showing appbar only if it should to be shown.
      builder: (_) => switch (state.tabsState.tab.get.shouldShowBackButton) {
        true => AppBar(
          leading: IconButton(
            onPressed: () => state.tabsState.tab.set(PageTab.main),
            icon: Icon(Icons.arrow_left_rounded),
          ),
        ),
        _ => SizedBox.shrink(),
      },
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, 80);
}

class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.state});

  final MyState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          // Changing tabs state.
          TextButton(
            onPressed: () => state.tabsState.tab.set(PageTab.main),
            child: Text('Main'),
          ),
          TextButton(
            onPressed: () => state.tabsState.tab.set(PageTab.settings),
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Settings')));
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.state});

  final MyState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Observing counter changes.
              TreeedObservable(
                stateToWatch: state.counter,
                builder: (_) => Text(state.counter.get.toString()),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // Changing counter state.
                  TextButton(
                    onPressed: () => state.counter.set(state.counter.get + 1),
                    child: Text('Add one'),
                  ),
                  TextButton(
                    onPressed: () => state.counter.set(0),
                    child: Text('Clear'),
                  ),

                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(height: 1, color: Colors.grey),
              ),

              // Setting user's date state.
              TextFormField(
                initialValue: state.subGroup.userName.get,
                decoration: InputDecoration.collapsed(hintText: 'Your name'),
                onChanged: (newName) => state.subGroup.userName.set(newName),
              ),
              SizedBox(height: 8),
              TextFormField(
                initialValue: state.subGroup.userAge.get.toString(),
                decoration: InputDecoration.collapsed(hintText: 'Your age'),
                keyboardType: TextInputType.number,
                onChanged: (newAge) => state.subGroup.userAge.set(
                  int.tryParse(newAge) ?? state.subGroup.userAge.get,
                ),
              ),

              SizedBox(height: 20),

              // Observing changes in user's data state.
              TreeedObservable(
                stateToWatch: state.subGroup,
                builder: (_) => Text(
                  'My name is: ${state.subGroup.userName.get}!'
                  ' And my age is: ${state.subGroup.userAge.get}.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
