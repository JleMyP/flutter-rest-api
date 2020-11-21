import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repos/imported_resources.dart';
import 'repos/user.dart';
import 'screens/about.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/profile.dart';
import 'screens/registration.dart';
import 'screens/settings.dart';
import 'utils/apiClient.dart';


void main() {
  runApp(MultiProvider(
    providers: [
      Provider(create: (context) => HttpApiClient()),
      ChangeNotifierProxyProvider<HttpApiClient, UserRepo>(
        create: (context) => UserRepo(),
        update: (context, client, repo) => repo..setClient(client),
      ),
      ProxyProvider<HttpApiClient, ImportedResourceRepo>(
        create: (context) => ImportedResourceRepo(),
        update: (context, client, repo) => repo..setClient(client),
      ),
    ],
    child: MaterialApp(
      title: 'Приложуха',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        primaryColor: Colors.green,
        accentColor: Colors.greenAccent[700],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/registration': (context) => RegistrationPage(),
        '/settings': (context) => SettingsPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/about': (context) => AboutPage(),
      },
    ),
  ));
}
