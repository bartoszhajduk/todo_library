import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xlo_auction_app/authentication/authentication.dart';
import 'package:xlo_auction_app/routes/add_auction.dart';
import 'package:xlo_auction_app/routes/archive_auction.dart';

class HomePage extends StatelessWidget {
  final List<Widget> _pages = [AddAuction(), ArchiveAuction()];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<FirebaseFirestore>(
            create: (_) => FirebaseFirestore.instance,
          ),
          Provider<FirebaseStorage>(
            create: (_) => FirebaseStorage.instance,
          ),
          Provider<AuthenticationService>(
            create: (_) => AuthenticationService(),
          ),
        ],
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.playlist_add),
                label: 'Add Auction',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.playlist_add_check),
                label: 'Archived',
              ),
            ],
          ),
          tabBuilder: (context, index) {
            return _pages[index];
          },
        ));
  }
}
