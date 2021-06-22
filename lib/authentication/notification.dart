import 'package:flutter/cupertino.dart';

void showNotification(BuildContext context, String title, String message) {
  showCupertinoDialog(
      context: context,
      builder: (context) {
        return NotificationDialog(title, message);
      });
}

class NotificationDialog extends StatelessWidget {
  final _errorTitle;
  final _errorMessage;
  NotificationDialog(this._errorTitle, this._errorMessage);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(_errorTitle),
      content: Text(_errorMessage),
      actions: [
        CupertinoButton(
          child: const Text('Ok'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
