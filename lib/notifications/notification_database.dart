/* This class supports SQLite operations on a frontend database that holds notifications. 
   Mainly stores unactionable background notifications such as friend request responses, news, and generally notifications that are
   only sent once by the server. */
import 'package:cao_prototype/models/friend_request.dart';
import 'package:cao_prototype/notifications/models/friend_request_response_notification.dart';
import 'package:cao_prototype/notifications/models/unactionable_notification.dart';
import 'package:cao_prototype/notifications/notification_manager.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class NotificationDatabase {
  static const String _databaseName = "notification_database.db";

  static Future<String> _getDatabasePath() async {
    return join(await getDatabasesPath(), _databaseName);
  }

  // checks whether the database exists
  static Future<bool> exists() async {
    String dbPath = await _getDatabasePath();
    return await databaseFactory.databaseExists(dbPath);
  }

  // creates a new database for storing unactionable notifications
  static Future<QueryResult> createLocalNotificationDatabase() async {
    QueryResult qr = QueryResult();
    try {
      String dbPath = await _getDatabasePath();
      // create database to store notifications
      Database db = await openDatabase(
        dbPath,
        version: 1,
      );
      String query =
          "create table NOTIFICATION (ID integer primary key autoincrement, TITLE text, BODY text, TYPE_CODE integer)";
      await db.execute(query);
      query =
          "create table FRIEND_REQUEST_RESPONSE (NOTIFICATION_ID integer, RECIPIENT_ID integer, RECIPIENT_ALIAS text)";
      await db.execute(query);
      query =
          "create table ASSOCIATION_INVITATION_RESPONSE (NOTIFICATION_ID integer, RECIPIENT_ID integer, RECIPIENT_ALIAS text)";
      await db.execute(query);

      qr.result = true;
      qr.data = true;
    } catch (e) {
      print(
          "Error in NotificationDatabase.createLocalNotificationDatabase(): $e");
      qr.result = false;
    }
    return qr;
  }

  // deletes the current database
  static Future<void> deleteDatabase() async {
    String dbPath = await _getDatabasePath();
    await databaseFactory.deleteDatabase(dbPath);
  }

  static Future<QueryResult> insertFriendRequestResponseNotification(
    FriendRequestResponseNotification frrn,
  ) async {
    QueryResult qr = QueryResult();

    try {
      String dbPath = await _getDatabasePath();
      Database db = await openDatabase(dbPath);

      int notificationCode = NotificationCodes.getCodeValue(frrn.type);

      String query =
          "insert into NOTIFICATION (TITLE,BODY,TYPE_CODE) values ('${frrn.title}','${frrn.body}',$notificationCode)";
      int notificationId = await db.rawInsert(query);
      query =
          "insert into FRIEND_REQUEST_RESPONSE (NOTIFICATION_ID,RECIPIENT_ID,RECIPIENT_ALIAS) values ($notificationId,${frrn.recipientId},'${frrn.recipientAlias}')";
      await db.rawInsert(query);
      qr.result = true;
      qr.data = true;
    } catch (e) {
      qr.result = false;
      qr.message =
          "Error in NotificationDatabase.insertFriendRequestResponseNotification(): $e";
    }

    return qr;
  }

  static Future<QueryResult> insertNotification(
      UnactionableNotification un) async {
    QueryResult qr = QueryResult();
    try {
      String dbPath = await _getDatabasePath();
      Database db = await openDatabase(dbPath);

      int notificationCode = NotificationCodes.getCodeValue(un.type);
      String query =
          "insert into NOTIFICATION (TITLE,BODY,TYPE_CODE) values ('${un.title}','${un.body}',$notificationCode)";
      await db.rawInsert(query);
      qr.result = true;
      qr.data = true;
    } catch (e) {
      qr.result = true;
      qr.message =
          "Error in NotificationDatabase.insertUnactionableNotification(): $e";
    }
    return qr;
  }

  // Gets all the notifications that were saved from the background. These should only include unactionable notifications.
  static Future<QueryResult> getUnactionableNotifications() async {
    QueryResult qr = QueryResult();
    try {
      List<UnactionableNotification> uns = List.empty(growable: true);

      String dbPath = await _getDatabasePath();
      Database db = await openDatabase(dbPath);

      // fetch friend request response notifications first ---------------------------------------------------------------------

      int notificationCode = NotificationCodes.getCodeValue(
        NotificationCodeKeys.FRIEND_REQUEST_RESPONSE,
      );

      String query =
          "select TITLE,BODY,TYPE_CODE,RECIPIENT_ID,RECIPIENT_ALIAS from NOTIFICATION as N inner join FRIEND_REQUEST_RESPONSE as FRR on N.ID = FRR.NOTIFICATION_ID where TYPE_CODE = $notificationCode";

      List<Map<String, Object?>> results = await db.rawQuery(query);

      for (Map result in results) {
        uns.add(
          FriendRequestResponseNotification.all(
            result["TITLE"],
            result["BODY"],
            result["RECIPIENT_ID"],
            result["RECIPIENT_ALIAS"],
          ),
        );
      }

      // fetch generic unactionable notifications ----------------------------------------------------------

      notificationCode = NotificationCodes.getCodeValue(
        NotificationCodeKeys.NONE,
      );
      query =
          "select TITLE,BODY,TYPE_CODE from NOTIFICATION where TYPE_CODE = $notificationCode;";
      results = await db.rawQuery(query);

      for (Map result in results) {
        NotificationCodeKeys key = NotificationCodes.getCodeKey(
          result["TYPE_CODE"],
        );
        uns.add(
          UnactionableNotification.all(
            key,
            result["TITLE"],
            result["BODY"],
          ),
        );
      }

      qr.data = uns;
      qr.result = true;
    } catch (e) {
      qr.result = false;
      qr.message =
          "Error in NotificationDatabase.getUnactionableNotifications(): $e";
    }
    return qr;
  }

  // returns the types of actionable notifications that are currently in the notification table
  static Future<QueryResult> getDistinctActionableNotificationCodeKeys() async {
    QueryResult qr = QueryResult();
    List<NotificationCodeKeys> actionableNotificationCodeKeys =
        List.empty(growable: true);
    try {
      String dbPath = await _getDatabasePath();
      Database db = await openDatabase(dbPath);

      String query =
          "select distinct(TYPE_CODE) as TYPE_CODE from NOTIFICATION;";

      List<Map<String, Object?>> results = await db.rawQuery(query);

      for (Map result in results) {
        int typeCode = result["TYPE_CODE"];
        if (NotificationCodes.getCodeKey(typeCode) ==
            NotificationCodeKeys.FRIEND_REQUEST) {
          actionableNotificationCodeKeys
              .add(NotificationCodeKeys.FRIEND_REQUEST);
        }
      }

      qr.result = true;
      qr.data = actionableNotificationCodeKeys;
    } catch (e) {
      qr.message =
          "Error in NotificationDatabase.getActionableNotificationCodes(): $e";
      qr.result = false;
    }

    return qr;
  }

  static Future<QueryResult> deleteNotifications() async {
    QueryResult qr = QueryResult();
    try {
      String dbPath = await _getDatabasePath();
      Database db = await openDatabase(dbPath);
      String query = "delete from NOTIFICATION;";
      db.rawQuery(query);
      query = "delete from FRIEND_REQUEST_RESPONSE;";
      db.rawQuery(query);
      query = "delete from ASSOCIATION_INVITATION_RESPONSE;";
      db.rawQuery(query);
      qr.result = true;
      qr.data = true;
    } catch (e) {
      qr.result = false;
      qr.message =
          "Error in NotificationDatabase.deleteUnactionableNotifications(): $e";
    }
    return qr;
  }
}
