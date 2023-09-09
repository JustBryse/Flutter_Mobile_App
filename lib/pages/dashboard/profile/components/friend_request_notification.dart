import 'package:cao_prototype/models/friend_request.dart';
import 'package:cao_prototype/pages/dashboard/profile/components/notification.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class FriendRequestNotificationWidget extends NotificationWidget {
  FriendRequest _friendRequest = FriendRequest.empty();
  FriendRequest get friendRequest => _friendRequest;

  FriendRequestNotificationWidget({
    Key? key,
    required String title,
    required FriendRequest friendRequest,
  }) : super(key: key, title: title) {
    _friendRequest = friendRequest;
  }

  @override
  State<FriendRequestNotificationWidget> createState() =>
      _FriendRequestNotificationWidgetState();
}

class _FriendRequestNotificationWidgetState
    extends State<FriendRequestNotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
