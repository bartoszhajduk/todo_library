import 'package:flutter/cupertino.dart';

void showAuthenticationNotification(
    BuildContext context, String errorTitle, String errorMessage) {
  showCupertinoDialog(
      context: context,
      builder: (context) {
        return AuthenticationNotificationDialog(errorTitle, errorMessage);
      });
}

class AuthenticationNotificationDialog extends StatelessWidget {
  final errorTitle;
  final errorMessage;
  AuthenticationNotificationDialog(this.errorTitle, this.errorMessage);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(errorTitle),
      content: Text(errorMessage),
      actions: [
        CupertinoButton(
          child: const Text('ok'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
