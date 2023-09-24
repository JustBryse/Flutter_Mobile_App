import 'package:cao_prototype/models/interest.dart';
import 'package:cao_prototype/support/queries.dart';

/* This class model represents the database table "user_interest" which associates a user to an actual interest from the "interest" table.
   This is needed due to the multiplicity relationships between users, interests, and universities. 
   When registering, the user's selected interests are inserted into the "user_interest" table with the help of this model class. */
class UserInterest {
  int _id = -1;
  int _userId = -1;
  int _interestId = -1;

  UserInterest.none();
  UserInterest.all(int id, int userId, int interestId) {
    _id = id;
    _userId = userId;
    _interestId = interestId;
  }

  int getId() {
    return _id;
  }

  int getUserId() {
    return _userId;
  }

  int getInterestId() {
    return _interestId;
  }
}
