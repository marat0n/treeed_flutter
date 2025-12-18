import 'dart:math';

import 'package:example/models.dart';
import 'package:flutter/widgets.dart';
import 'package:treeed_flutter/loadable.dart';
import 'package:treeed_flutter/treeed_flutter.dart';

// Easily made, testable and type-safe dependency container.
class DI extends TreeedGroup {
  // Static dependency.
  final repository = Repository();

  // Dependency with changing state.
  late final appState = tg(AppState());
}

// Mocked repository dependency. Methods have a 50% chance to fail.
class Repository {
  Future<TextResponse> fetchGreetings() async {
    return Random().nextBool()
        ? Got("Fetched greetings to the World!")
        : Failure(
            LoadingError(
              errorMessage: "Something went wrong...",
              errorCode: 500,
            ),
          );
  }

  Future<UserResponse> fetchUser() async {
    return Random().nextBool()
        ? Got(User(name: "Douglas Adams", age: 42, id: 0))
        : Failure(
            LoadingError(
              errorMessage:
                  "Database is crashed, servers are on fire, user not found!",
              errorCode: 500,
            ),
          );
  }
}

// App state dependency.
class AppState extends TreeedGroup {
  late final user = tsLoadableFailable<User, LoadingError>();
  late final theme = ts(Brightness.light);
}
