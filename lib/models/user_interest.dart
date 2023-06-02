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

  static _getNextId() async {
    QueryResult qr = QueryResult();
    String query = "select max(uiId) as maxId from user_interest";
    try {
      var con = await Queries.getConnection();
      var result = await con.query(query);
      con.close();

      qr.data = result.first["maxId"] + 1;

      qr.result = true;
    } catch (e) {
      qr.result = false;
      print("Error in UserInterest._getNextId(): $e");
    }
    return qr;
  }

  // inserts a user interest and returns a query result that contains the inserted user interest in the data property
  static insertUserInterest(Interest interest, int userId) async {
    QueryResult qr = QueryResult();
    try {
      qr = await _getNextId();

      if (qr.result == false) {
        throw Exception("Failed to get next user_interest id.");
      }

      UserInterest userInterest =
          UserInterest.all(qr.data, userId, interest.getId());
      String query =
          "insert into user_interest values (${userInterest._id.toString()},${userInterest._userId.toString()},${userInterest._interestId.toString()})";
      var con = await Queries.getConnection();
      await con.query(query);
      qr.data = userInterest;
      qr.result = true;
    } catch (e) {
      qr.message = "Failed to insert the user's interest.";
      print("Error in UserInterest.insertUserInterest(): $e");
    }

    return qr;
  }

  // inserts a list of user interests and returns a query result that contains the inserted list in the data property
  static insertUserInterests(List<Interest> interests, int userId) async {
    QueryResult qr = QueryResult();
    try {
      for (Interest interest in interests) {
        var _qr = await insertUserInterest(interest, userId);
        if (_qr.result == false) {
          throw Exception("Bad insertion attempt of user's interests.");
        }
      }
      qr.data = interests;
      qr.result = true;
    } catch (e) {
      qr.message = "Failed to insert the user's interests.";
      print("Error in UserInterest.insertUserInterests(): $e");
    }

    return qr;
  }
}
