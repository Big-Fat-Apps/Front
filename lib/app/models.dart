import 'package:flutter/material.dart';
import 'package:trading/app/app.dart';

class UserModel extends ChangeNotifier {
  bool isLoggedIn = false;
  int loginId = -1;
  bool isAdmin = false;

  void logIn(int loginId_, bool isAdmin_) {
    isLoggedIn = true;
    loginId = loginId_;
    isAdmin = isAdmin_;
    notifyListeners();
  }

  void logOut(BuildContext context) {
    isLoggedIn = false;
    loginId = -1;
    isAdmin = false;
    Navigator.of(context).restorablePushNamed(TradingApp.loginRoute);
    notifyListeners();
  }
}
