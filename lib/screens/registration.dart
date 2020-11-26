import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repos/user.dart';
import '../utils/dialogs.dart';
import '../utils/validators.dart';


class RegistrationPage extends StatefulWidget {
  @override
  RegistrationPageState createState() => RegistrationPageState();
}


class RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> actions;  // TODO: относительно дубль
    if (_isLoading) {
      actions = [Center(child: CircularProgressIndicator())];
    } else {
      actions = [
        RaisedButton(
          child: Text('Зарегистрироваться'),
          onPressed: _register,
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Регистрация'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
          children: [
            TextFormField(
              controller: _loginController,
              validator: requiredString,
              decoration: InputDecoration(labelText: 'Логин'),
              enabled: !_isLoading,
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              controller: _passwordController,
              validator: requiredString,
              decoration: InputDecoration(labelText: 'Пароль'),
              enabled: !_isLoading,
            ),
            TextFormField(
              controller: _confirmPasswordController,
              validator: requiredString,
              decoration: InputDecoration(labelText: 'Пароль еще раз'),
              enabled: !_isLoading,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'Имя'),
              enabled: !_isLoading,
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Фамилия'),
              enabled: !_isLoading,
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              controller: _middleNameController,
              decoration: InputDecoration(labelText: 'Отчество'),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 30),
            ...actions,
          ],
        ),
      ),
    );
  }

  _register() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    // TODO: валидация паролей

    var userRepo = context.read<UserRepo>();
    setState(() => _isLoading = true);
    try {
      await userRepo.register(
        _loginController.text,
        _passwordController.text,
        _firstNameController.text,
        _lastNameController.text,
        _middleNameController.text,
      );
    } on Exception catch (e) {
      await showSimpleDialog(context, 'Регистрация не удалась (', e.toString());
    }

    await _storeAuth();
    await Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
  }

  _storeAuth() async {  // TODO: дубль. мб в репу?
    var sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('auth:login', _loginController.text);
    sharedPreferences.setString('auth:password', _passwordController.text);
    sharedPreferences.setBool('auth:autoLogin', true);
  }
}
