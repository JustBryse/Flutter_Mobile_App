import "package:cao_prototype/models/user.dart";

abstract class Session {
  static User currentUser = User.none();
}
