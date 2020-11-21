import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../repos/user.dart';
import '../utils/dialogs.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  bool _isLoading = false;

  @override
  initState() {
    super.initState();
    var userRepo = context.read<UserRepo>();
    var user = userRepo.currentUser;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _middleNameController.text = user.middleName;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions;
    if (_isLoading) {
      actions = [Center(child: CircularProgressIndicator())];
    } else {
      actions = [
        RaisedButton(
          child: Text('Сохранить'),
          onPressed: () => _update(context),
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'Имя'),
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Фамилия'),
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              controller: _middleNameController,
              decoration: InputDecoration(labelText: 'Отчество'),
            ),
            const SizedBox(height: 30),
            ...actions,
          ],
        ),
      ),
    );
  }

  _update(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    var userRepo = context.read<UserRepo>();
    setState(() => _isLoading = true);

    try {
      await userRepo.update(
        _firstNameController.text,
        _lastNameController.text,
        _middleNameController.text,
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isLoading = false);
      await showSimpleDialog(context, 'Не удалось обновить профиль', e.toString());
    }
  }
}
