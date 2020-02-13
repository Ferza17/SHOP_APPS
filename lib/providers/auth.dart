import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//Models
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  static const _webApi = 'AIzaSyDY6Rf0XwgqxYqhF8NRWXY9JpYSbHSu8_s';
  String _token;
  DateTime _expirationDate;
  String _userId;

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
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
