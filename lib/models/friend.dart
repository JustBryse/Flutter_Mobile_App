import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/support/queries.dart';

// BasicFriend represents a single record of the FRIEND table in the SQL database
class BasicFriend {
  int _frienderId = -1;
  int _friendedId = -1;
  int _friendLevel = -1;
  DateTime _insertDate = DateTime(0);
  DateTime _editDate = DateTime(0);

  DateTime get insertDate => _insertDate;
  DateTime get editDate => _editDate;

  BasicFriend(int frienderId, int friendedId) {
    _frienderId = frienderId;
    _friendedId = friendedId;
  }

  static Future<QueryResult> deleteFriend(BasicFriend bf) async {
    throw Exception("Not implemented.");
  }
}

class Friend extends BasicFriend {
  // the friender is the current user
  User _friender = User.none();
  // the friended is the person who was "friended" by the friender
  User _friended = User.none();

  Friend.fetch(
    User friender,
    User friended,
    int friendLevel,
    DateTime insertDate,
    DateTime editDate,
  ) : super(friender.id, friended.id) {
    _friender = friender;
    _friended = friended;
    _friendLevel = friendLevel;
    _insertDate = insertDate;
    _editDate = editDate;
  }

  // gets the friends of the current user
  static Future<QueryResult> getFriends() async {
    throw Exception("Not implemented.");
  }
}
