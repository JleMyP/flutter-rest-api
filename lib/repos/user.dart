import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../utils/api_client.dart';


class UserRepo with ChangeNotifier {
  HttpApiClient client;
  User currentUser;

  UserRepo();
  UserRepo.withClient(this.client);

  setClient(HttpApiClient client) {
    this.client = client;
  }

  Future<User> authenticate(String username, String password) async {
    if (client.fake) {
      await Future.delayed(Duration(seconds: 2));
      currentUser = User(
        username: username,
        firstName: 'Имя',
        lastName: 'Фамилия',
        middleName: 'Отчество',
      );
    } else {
      var authData = {'username': username, 'password': password};
      await client.authenticate(authData);
      var response = await client.get('/profile/');
      currentUser = User(
        username: username,
        firstName: response['first_name'],
        lastName: response['last_name'],
        middleName: response['middle_name'],
      );
    }
    notifyListeners();
    return currentUser;
  }

  Future<User> register(String username, String password,
      [String firstName, String lastName, String middleName]) async {
    if (client.fake) {
      await Future.delayed(Duration(seconds: 2));
      currentUser = User(
        username: username,
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
      );
    } else {
      var data = {
        'username': username,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'middle_name': middleName,
      };
      var response = await client.post('/registration/', data);
      currentUser = User(
        username: username,
        firstName: response['first_name'],
        lastName: response['last_name'],
        middleName: response['middle_name'],
      );
      authenticate(username, password);  // TODO: дубль получения профиля
    }
    notifyListeners();
    return currentUser;
  }

  Future<User> update([String firstName, String lastName,
      String middleName]) async {
    if (client.fake) {
      await Future.delayed(Duration(seconds: 2));
    } else {
      var data = {
        'first_name': firstName,
        'last_name': lastName,
        'middle_name': middleName,
      };
      await client.patch('/profile/', data);
    }
    currentUser = User(
      username: currentUser.username,
      firstName: firstName,
      lastName: lastName,
      middleName: middleName,
    );
    notifyListeners();
    return currentUser;
  }

  logout() {
    currentUser = null;
    client.logout();
  }
}
