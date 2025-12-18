import 'package:treeed_flutter/loadable.dart';
import 'package:treeed_flutter/treeed_flutter.dart';

typedef UserResponse = LoadableValue<User, LoadingError>;
typedef TextResponse = LoadableValue<String, LoadingError>;

class LoadingError {
  final String errorMessage;
  final int errorCode;

  LoadingError({required this.errorMessage, required this.errorCode});
}

class User {
  final int id;
  final String name;
  final int age;

  User({required this.name, required this.age, required this.id});
}

class UserChangesState extends TreeedGroup {
  final User baseUser;
  late final name = ts(baseUser.name);
  late final age = ts(baseUser.age);

  UserChangesState({required this.baseUser});
}
