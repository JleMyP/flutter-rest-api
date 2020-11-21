import 'package:flutter/material.dart';


showSimpleDialog(BuildContext parentContext, String title, String content) async {
  await showDialog(
    context: parentContext,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        FlatButton(
          child: Text('ОК'),
          onPressed: () => Navigator.of(parentContext).pop(),
        ),
      ],
    ),
  );
}
