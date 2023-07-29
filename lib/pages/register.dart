import 'package:cao_prototype/models/individual.dart';
import 'package:cao_prototype/models/organization.dart';
import 'package:cao_prototype/models/user_interest.dart';
import 'package:flutter/material.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/models/university.dart';
import 'package:cao_prototype/models/interest.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // keeps track of the current account type that the user is trying to register as and is used as a flag for toggling UI widgets
  AccountTypes selectedAccountType = AccountTypes.INDIVIDUAL;
  // Holds all the university item widgets that are used in the university dropdown UI. This list is populated on load.
  List<DropdownMenuItem<University>> universityDropDownItems =
      List.empty(growable: true);
  // Holds the currently selected university from a dropdown menu. Determines interest options later in the register UI.
  University selectedUniversity = University.none();
  // Holds a list of interests that are associated to the currently selected university. This is fetched from the database when the user chooses a university.
  List<MultiSelectItem<Interest>> universityInterestSelectItems =
      List.empty(growable: true);
  // Holds a list of interests that the user has selected
  List<Interest> selectedInterests = List.empty(growable: true);

  // all the input field controllers
  final TextEditingController aliasTEC = TextEditingController();
  final TextEditingController emailTEC = TextEditingController();
  final TextEditingController password1TEC = TextEditingController();
  final TextEditingController password2TEC = TextEditingController();
  final TextEditingController individualFirstNameTEC = TextEditingController();
  final TextEditingController individualLastNameTEC = TextEditingController();
  final TextEditingController organizationNameTEC = TextEditingController();

  // keeps track of whether a database query is in progress and is used to toggle the UI
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUniversities();
  }

  // builds a list of universities that the user can select from based on the universities in the database
  void getUniversities() async {
    setState(() {
      universityDropDownItems.clear();
      isLoading = true;
    });

    var universities;

    try {
      var qr = await University.getUniversities();

      if (qr.result == false) {
        throw Exception("Bad query result when fetching universities.");
      }

      universities = qr.data;

      for (var university in universities) {
        universityDropDownItems.add(
          DropdownMenuItem(
            value: university,
            child: Text(
              university.getName(),
              style: const TextStyle(fontSize: 20, color: Utility.primaryColor),
            ),
          ),
        );
      }
    } catch (e) {
      // if the database query failed then add a dummy item
      universityDropDownItems.add(DropdownMenuItem(
        value: University.none(),
        child: const Text(
          "None",
          style: TextStyle(fontSize: 20, color: Utility.primaryColor),
        ),
      ));

      Utility.displayAlertMessage(context, "Failed to Fetch Data",
          "Failed to fetch university information. Please exit the page and try again.");
    }

    setState(() {
      universityDropDownItems;
      chooseUniversity(universities[0]);
      isLoading = false;
    });
  }

  /* Builds a list of interests by fetching the interests that are associated to the university that is currently selected by the user.
  /  This function is called when the user changes their currently selected university. */
  void getInterests(University university) async {
    try {
      setState(() {
        universityInterestSelectItems.clear();
        selectedInterests.clear();
      });
      var qr = await Interest.getInterests(university.getId());

      if (qr.result == false) {
        throw Exception("Bad query result when fetching interests.");
      }

      var interests = qr.data;

      for (var interest in interests) {
        MultiSelectItem<Interest> item =
            MultiSelectItem(interest, interest.toString());
        universityInterestSelectItems.add(item);
      }

      setState(() {
        universityDropDownItems;
      });
    } catch (e) {
      Utility.displayAlertMessage(context, "Failed to Fetch Data",
          "Failed to fetch interests. Please exit the page and try again.");
    }
  }

  // attempt to create a new user account, the data attribute of the QueryResult is a boolean
  void register() async {
    // check if the user entered the required information in the input fields
    if (aliasTEC.text.isEmpty ||
        emailTEC.text.isEmpty ||
        password1TEC.text.isEmpty ||
        password2TEC.text.isEmpty ||
        password1TEC.text != password2TEC.text) {
      Utility.displayAlertMessage(context, "Invalid Credentials",
          "Please ensure that passwords match and all fields are complete");
      return;
    } else if (aliasTEC.text.length > 255 ||
        emailTEC.text.length > 255 ||
        password1TEC.text.length > 255 ||
        password2TEC.text.length > 255) {
      Utility.displayAlertMessage(context, "Invalid Credentials",
          "One of your inputs has a length that exceeds 255 characters");
      return;
    } else if (selectedAccountType == AccountTypes.INDIVIDUAL &&
        (individualFirstNameTEC.text.isEmpty ||
            individualLastNameTEC.text.isEmpty)) {
      Utility.displayAlertMessage(
          context, "Invalid Credentials", "Please enter a first and last name");
      return;
    } else if (selectedAccountType == AccountTypes.ORGANIZATION &&
        organizationNameTEC.text.isEmpty) {
      Utility.displayAlertMessage(
          context, "Invalid Credentials", "Please enter an organization name.");
      return;
    }

    // QueryResult variable for interpreting responses from the database API
    var qr;

    // attempt to create a User account
    try {
      setState(() {
        isLoading = true;
      });

      // INSERTING INDIVIDUAL OR ORGANIZATION

      if (selectedAccountType == AccountTypes.INDIVIDUAL) {
        qr = await Individual.registerIndividual(
            emailTEC.text,
            password1TEC.text,
            aliasTEC.text,
            individualFirstNameTEC.text,
            individualLastNameTEC.text,
            selectedInterests);

        if (qr.result == false) {
          throw Exception("Failed to create account with role: individual.");
        }
      } else if (selectedAccountType == AccountTypes.ORGANIZATION) {
        qr = await Organization.registerOrganization(
            emailTEC.text,
            password1TEC.text,
            aliasTEC.text,
            organizationNameTEC.text,
            selectedInterests);

        if (qr.result == false) {
          throw Exception("Failed to create account with role: organization.");
        }
      }

      // POPPING THE PAGE AND RETURNING TO THE HOME PAGE WITH ACCOUNT REGISTERING SUCCESS RESULT
      var response = {"registered": true, "email": emailTEC.text};
      // pop the register page and inform the user that their account has been created
      Navigator.pop(context, response);
    } catch (e) {
      print("Error in _HomePageState.register(): " + e.toString());
      Utility.displayAlertMessage(context, "Register Failed", qr.message);
    }
    setState(() {
      isLoading = false;
    });
  }

  // used for selecteding an account type from a dropdown menu
  void chooseAccountType(account) {
    setState(() {
      selectedAccountType = account;
    });
  }

  // Used for selecting a university from a dropdown menu. Queries interests from the database that are associated to a university.
  // Populates the interests UI with options pertaining to the selected university
  void chooseUniversity(university) async {
    setState(() {
      selectedUniversity = university;
    });

    getInterests(selectedUniversity);
  }

  void chooseInterests(interests) {
    setState(() {
      selectedInterests = interests;
    });
  }

  Color getMultiSelectItemColor(Interest interest) {
    return Utility.primaryColorTranslucent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CAO",
          style: TextStyle(
              fontSize: Utility.titleFontSize, color: Utility.secondaryColor),
        ),
        backgroundColor: Utility.primaryColor,
      ),
      body: isLoading
          ? Container(
              color: Utility.tertiaryColor,
              child: const Center(
                child: Text(
                  "Loading. Please wait.",
                  style: TextStyle(fontSize: 20, color: Utility.secondaryColor),
                ),
              ),
            )
          : Container(
              color: Utility.tertiaryColor,
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: DropdownButton(
                          value: selectedAccountType,
                          onChanged: chooseAccountType,
                          items: [
                            DropdownMenuItem(
                              value: AccountTypes.INDIVIDUAL,
                              child: Row(
                                children: const [
                                  Icon(Icons.person),
                                  Text(
                                    "Individual",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Utility.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: AccountTypes.ORGANIZATION,
                              child: Row(
                                children: const [
                                  Icon(Icons.group),
                                  Text(
                                    "Organization",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Utility.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 1.25,
                          height: 50,
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: "Alias",
                              labelStyle:
                                  TextStyle(color: Utility.primaryColor),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Utility.primaryColor),
                              ),
                            ),
                            controller: aliasTEC,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 1.25,
                          height: 50,
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: "Email",
                              labelStyle:
                                  TextStyle(color: Utility.primaryColor),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Utility.primaryColor),
                              ),
                            ),
                            controller: emailTEC,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 1.25,
                          height: 50,
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: "Password",
                              labelStyle:
                                  TextStyle(color: Utility.primaryColor),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Utility.primaryColor),
                              ),
                            ),
                            controller: password1TEC,
                            obscureText: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 1.25,
                          height: 50,
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: "Confirm Password",
                              labelStyle:
                                  TextStyle(color: Utility.primaryColor),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Utility.primaryColor),
                              ),
                            ),
                            controller: password2TEC,
                            obscureText: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // input fields for the invidual account type
                  (selectedAccountType == AccountTypes.INDIVIDUAL)
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width /
                                        1.25,
                                    height: 50,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        labelText: "First Name",
                                        labelStyle: TextStyle(
                                            color: Utility.primaryColor),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Utility.primaryColor),
                                        ),
                                      ),
                                      controller: individualFirstNameTEC,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width /
                                        1.25,
                                    height: 50,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        labelText: "Last Name",
                                        labelStyle: TextStyle(
                                            color: Utility.primaryColor),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Utility.primaryColor),
                                        ),
                                      ),
                                      controller: individualLastNameTEC,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      // input fields for the organization account type
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width /
                                        1.25,
                                    height: 50,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        labelText: "Organization Name",
                                        labelStyle: TextStyle(
                                            color: Utility.primaryColor),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Utility.primaryColor),
                                        ),
                                      ),
                                      controller: organizationNameTEC,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: DropdownButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: chooseUniversity,
                          value: selectedUniversity,
                          items: universityDropDownItems,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: MultiSelectDialogField<Interest>(
                          selectedColor: Utility.primaryColorTranslucent,
                          backgroundColor: Utility.tertiaryColor,
                          buttonIcon: const Icon(Icons.arrow_drop_down),
                          buttonText: const Text(
                            "Interests",
                            style: TextStyle(
                                fontSize: 20, color: Utility.primaryColor),
                          ),
                          title: const Text(
                            "Interests",
                            style: TextStyle(color: Utility.primaryColor),
                          ),
                          confirmText: const Text(
                            "Confirm",
                            style: TextStyle(color: Utility.primaryColor),
                          ),
                          cancelText: const Text(
                            "Cancel",
                            style: TextStyle(color: Utility.primaryColor),
                          ),
                          //colorator: getMultiSelectItemColor,
                          decoration:
                              const BoxDecoration(color: Utility.tertiaryColor),
                          searchable: true,
                          searchIcon: const Icon(Icons.search),
                          closeSearchIcon: const Icon(Icons.close),
                          listType: MultiSelectListType.CHIP,
                          items: universityInterestSelectItems,
                          initialValue: const [],
                          onConfirm: chooseInterests,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AbsorbPointer(
                        absorbing: isLoading,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            color: Utility.primaryColor,
                            width: MediaQuery.of(context).size.width / 3,
                            height: 50,
                            child: TextButton(
                              onPressed: register,
                              child: const Text(
                                "Register",
                                style: TextStyle(color: Utility.secondaryColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
