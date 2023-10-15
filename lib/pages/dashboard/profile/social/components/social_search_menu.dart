import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/pages/dashboard/profile/social/components/user_widget.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';

class SocialSearchMenu extends StatefulWidget {
  void Function() _getFriendsAndContacts = () {};
  SocialSearchMenu({
    Key? key,
    required void Function() getFriendsAndContacts,
  }) : super(key: key) {
    _getFriendsAndContacts = getFriendsAndContacts;
  }

  @override
  State<SocialSearchMenu> createState() => _SocialSearchMenuState();
}

class _SocialSearchMenuState extends State<SocialSearchMenu> {
  List<User> users = List.empty(growable: true);
  List<UserWidget> userWidgets = List.empty(growable: true);

  TextEditingController searchTEC = TextEditingController();

  void search() async {
    users.clear();
    userWidgets.clear();

    if (searchTEC.text.isEmpty) {
      return;
    }

    QueryResult qr = await User.getUsersByAlias(searchTEC.text);

    if (qr.result == false) {
      Utility.displayAlertMessage(
          context, "Failed to Search", "Please try again.");
      return;
    }
    double width = MediaQuery.of(context).size.width * 0.9;
    for (User u in qr.data) {
      users.add(u);
      userWidgets.add(
        UserWidget(
          user: u,
          width: width,
          getFriendsAndContacts: widget._getFriendsAndContacts,
        ),
      );
    }

    setState(() {
      userWidgets;
    });
  }

  Widget? buildUserWidgets(BuildContext bc, int index) {
    if (index == 0) {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Utility.secondaryColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: " Enter User Alias",
                      hintStyle: TextStyle(
                        color: Utility.tertiaryColor,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    cursorColor: Utility.primaryColor,
                    controller: searchTEC,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: search,
                  icon: const Icon(
                    Icons.search,
                    color: Utility.primaryColorTranslucent,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (userWidgets.isNotEmpty && index < userWidgets.length + 1) {
      return userWidgets[index - 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Utility.primaryColor,
      child: ListView.builder(
        itemBuilder: buildUserWidgets,
      ),
    );
  }
}
