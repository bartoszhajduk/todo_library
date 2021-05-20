import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:xlo_auction_app/authentication/authentication.dart';

class Account extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Homepage'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (clicked) => handleClick(context, clicked),
            itemBuilder: (BuildContext context) {
              return {'Logout', 'Settings'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
    );
  }

  void handleClick(BuildContext context, String value) {
    final _auth = context.read<AuthenticationService>();

    switch (value) {
      case 'Logout':
        _auth.logout();
        break;
    }
  }
}
