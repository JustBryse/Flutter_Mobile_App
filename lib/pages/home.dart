import 'dart:convert';

import 'package:cao_prototype/models/individual.dart';
import 'package:cao_prototype/models/organization.dart';
import 'package:cao_prototype/pages/register.dart';
import 'package:cao_prototype/pages/dashboard/dashboard.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:flutter/material.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:cao_prototype/support/server.dart';
import 'package:cao_prototype/models/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController emailTEC = TextEditingController();
  final TextEditingController passwordTEC = TextEditingController();
  // used to record the state of whether the user is logging in
  bool isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    loginWithLocalCredentials();
  }

  // attempt to login, the data attribute of the QueryResult is a User instance
  void login() async {
    if (emailTEC.text.isEmpty || passwordTEC.text.isEmpty) {
      Utility.displayAlertMessage(context, "Invalid Credentials",
          "Please enter a valid email and password");
      return;
    }

    setState(() {
      isLoggingIn = true;
    });

    QueryResult qr = await Session.login(
      LoginRoutes.MANUAL_LOGIN,
      emailTEC.text,
      passwordTEC.text,
    );

    // load dashboard page
    if (qr.result) {
      // If it doesn't already exist, store the user's credentials locally to log-in automatically next time
      bool result = await Session.saveUserCredentialsLocally(
          Session.currentUser.email, Session.currentUser.password);

      setState(() {
        isLoggingIn = false;
      });
      pushDashboardPage();
    } else {
      Utility.displayAlertMessage(context, "Failed to Sign In",
          "Please check your credentials and try again.");
    }

    // enable the login UI once the login query is complete regardless of result
    setState(() {
      isLoggingIn = false;
    });
  }

  // attempt to login automatically with the most recent user credentials that were used to log in
  void loginWithLocalCredentials() async {
    setState(() {
      isLoggingIn = true;
    });

    Map<String, Object?> credentials = await Session.getLocalUserCredentials();
    if (credentials.isEmpty) {
      setState(() {
        isLoggingIn = false;
      });
      return;
    }

    if (credentials["EMAIL"] != null && credentials["PASSWORD"] != null) {
      QueryResult qr = await Session.login(
        LoginRoutes.AUTOMATIC_LOGIN,
        credentials["EMAIL"].toString(),
        credentials["PASSWORD"].toString(),
      );

      print(qr);

      if (qr.result) {
        setState(() {
          isLoggingIn = false;
        });
        pushDashboardPage();
      } else {
        Utility.displayAlertMessage(context, "Failed to Sign In",
            "Please check your credentials and try again.");
      }
    }

    setState(() {
      isLoggingIn = false;
    });
  }

  void pushDashboardPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardPage(),
      ),
    );
  }

  // navigate to the register page, recieves a boolean from the register page that if true indicates the creation of a User account
  void pushRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    ).then((result) => {
          if (result != null)
            {
              if (result["registered"] == true)
                {
                  Utility.displayAlertMessage(context, "Register Successful",
                      "Welcome " + result["email"] + " to Campus Orbis.")
                }
            }
        });
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
      body: isLoggingIn
          ? Container(
              color: Utility.tertiaryColor,
              child: const Center(
                child: Text(
                  "Logging in. Please wait.",
                  style: TextStyle(fontSize: 20, color: Utility.secondaryColor),
                ),
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Utility.tertiaryColor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.25,
                      height: 50,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: Utility.primaryColor),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Utility.primaryColor),
                          ),
                        ),
                        controller: emailTEC,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.25,
                      height: 50,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: Utility.primaryColor),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Utility.primaryColor),
                          ),
                        ),
                        controller: passwordTEC,
                        obscureText: true,
                      ),
                    ),
                  ),
                  AbsorbPointer(
                    absorbing: isLoggingIn,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        color: Utility.primaryColor,
                        width: MediaQuery.of(context).size.width / 3,
                        height: 50,
                        child: TextButton(
                          onPressed: login,
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Utility.secondaryColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: 50,
                    color: Utility.primaryColor,
                    child: TextButton(
                      onPressed: pushRegisterPage,
                      child: const Text(
                        "Register",
                        style: TextStyle(color: Utility.secondaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
