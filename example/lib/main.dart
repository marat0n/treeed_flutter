import 'package:example/di.dart';
import 'package:example/models.dart';
import 'package:flutter/material.dart';
import 'package:treeed_flutter/loadable.dart';
import 'package:treeed_flutter/treeed_flutter.dart';

void main() {
  final di = DI();
  runApp(MyApp(di: di));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.di});

  final DI di;

  @override
  Widget build(BuildContext context) {
    return di.appState.theme.observable(
      builder: (_) {
        return MaterialApp(
          theme: di.appState.theme.get == Brightness.dark
              ? ThemeData.dark()
              : ThemeData.light(),
          home: MainPage(state: di.appState, repo: di.repository),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.state, required this.repo});

  final AppState state;
  final Repository repo;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TreeedWidget {
  /// All sets to this state created by `ts` (from `TreeedWidget` mixin)
  /// will call `setState` for this widget.
  late final greetings = ts<LoadableValue<String, LoadingError>>(Loading());

  late final changingUser = ts(
    UserChangesState(baseUser: User(name: "", age: 0, id: 0))
      ..listen(callUpdateState),
  );

  @override
  void initState() {
    final emptyUser = User(name: "", age: 0, id: 0);

    // Fetching the data.
    widget.repo.fetchUser();
    widget.repo.fetchGreetings();

    // Reapplying new fetched data.
    widget.state.user.listen((updated) {
      final user = updated.valueOr(emptyUser);
      changingUser.get.name.set(user.name);
      changingUser.get.age.set(user.age);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = widget.state.theme;
    return Scaffold(
      appBar: AppBar(title: Text("Treeed for Flutter example")),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 15,
        children: [
          FloatingActionButton.small(
            onPressed: () => themeState.set(
              themeState.get == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
            ),
            child: themeState.observable(
              builder: (_) => themeState.get == Brightness.dark
                  ? Icon(Icons.sunny)
                  : Icon(Icons.mode_night),
            ),
          ),
          FloatingActionButton.large(
            onPressed: () {
              widget.repo.fetchUser().then(
                (user) => widget.state.user.set(user),
              );
              widget.repo.fetchGreetings().then((text) => greetings.set(text));
            },
            child: Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 25,
          children: [
            Text(
              "Greetings section:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            switch (greetings.get) {
              Got(value: final data) => Text(data),
              Failure(error: final err) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Icon(Icons.error),
                  Text("Failure: ${err.errorMessage}"),
                ],
              ),
              _ => Text(
                "Loading...",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            },

            Text(
              "User section:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            widget.state.user.observable(
              builder: (context) => switch (widget.state.user.get) {
                Got(value: final data) => Text(
                  "Fetched user: ${data.name}, ${data.age}yo.",
                ),
                Failure(error: final err) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [Icon(Icons.error), Text(err.errorMessage)],
                ),
                _ => Text(
                  "Loading user...",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              },
            ),

            Text("Changed user's name: ${changingUser.get.name.get}"),

            // You can do better with TextEditingController.
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: TextField(
                onChanged: (newName) =>
                    changingUser.set(changingUser.get..name.set(newName)),
              ),
            ),

            Text("Changed user's age: ${changingUser.get.age.get}"),

            Padding(
              padding: const EdgeInsets.all(28.0),
              child: TextField(
                onChanged: (newAge) => changingUser.set(
                  changingUser.get
                    ..age.set(int.parse(newAge.isEmpty ? "0" : newAge)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
