import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

//Models
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  static const _webApi = 'AIzaSyDY6Rf0XwgqxYqhF8NRWXY9JpYSbHSu8_s';
  String _token;
  DateTime _expirationDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expirationDate != null &&
        _expirationDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  void signout() {
    _token = null;
    _userId = null;
    _expirationDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expirationDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), signout);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extrectedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expirationDate = DateTime.parse(extrectedUserData['expirationDate']);

    if(expirationDate.isBefore(DateTime.now())){
      return false;
    }

    _token = extrectedUserData['token'];
    _userId = extrectedUserData['userId'] ;
    _expirationDate = expirationDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    var url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=" +
            _webApi;
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            "email": email,
            "password": password,
            "returnSecureToken": true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      print(responseData);
      _token = responseData['idToken'];
      _expirationDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _userId = responseData['localId'];
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      // U can use json.encode inside setString
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expirationDate': _expirationDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }
}
