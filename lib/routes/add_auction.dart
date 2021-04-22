import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:xlo_auction_app/authentication/authentication.dart';

class AddAuction extends StatefulWidget {
  @override
  _AddAuctionState createState() => _AddAuctionState();
}

class _AddAuctionState extends State<AddAuction> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<Asset> images = <Asset>[];
  List<String> imageUrls = <String>[];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('co jest?'),
          ),
          child: SafeArea(
            child: Column(
              children: [
                CupertinoTextField(
                  controller: titleController,
                  placeholder: 'title',
                ),
                CupertinoTextField(
                  controller: descriptionController,
                  placeholder: 'description',
                  keyboardType: TextInputType.multiline,
                  maxLines: 8,
                ),
                CupertinoButton(
                  child: Text('pick images'),
                  onPressed: () => loadAssets(),
                ),
                Expanded(child: buildGridView()),
                CupertinoButton(
                  child: Text('add auction'),
                  onPressed: () => addAuction(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      log(e.toString());
    }

    setState(() {
      images = resultList;
    });
  }

  Widget buildGridView() {
    if (images != null)
      return GridView.count(
        crossAxisCount: 4,
        children: List.generate(images.length, (index) {
          Asset asset = images[index];
          return AssetThumb(
            asset: asset,
            width: 300,
            height: 300,
          );
        }),
      );
    else
      return Container(color: CupertinoColors.activeBlue);
  }

  Future<void> addAuction(BuildContext context) async {
    final _auth = context.read<AuthenticationService>();
    final _firestore = context.read<FirebaseFirestore>();

    await uploadImages(context);

    CollectionReference _userAuctions = _firestore
        .collection('users')
        .doc(_auth.getCurrentUserId())
        .collection('auctions');

    final documentSnapshot = await _userAuctions.add({
      'title': titleController.text,
      'description': descriptionController.text,
      'email': _auth.getCurrentUserEmail()
    });

    documentSnapshot.update({'images': FieldValue.arrayUnion(imageUrls)});
  }

  Future<void> uploadImages(BuildContext context) async {
    final _auth = Provider.of<AuthenticationService>(context, listen: false);
    final _storage = Provider.of<FirebaseStorage>(context, listen: false);
    final loggedUser = _auth.getCurrentUserId();

    for (var imageAsset in images) {
      final imageName = imageAsset.name;
      File imageFile = await getImageFileFromAssets(imageAsset);

      final taskSnapshot = await _storage
          .ref()
          .child('$loggedUser/$imageName')
          .putFile(imageFile);

      final imageUrl = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        imageUrls.add(imageUrl);
      });
    }
  }

  Future<File> getImageFileFromAssets(Asset asset) async {
    final byteData = await asset.getByteData();

    final tempFile =
        File("${(await getTemporaryDirectory()).path}/${asset.name}");
    final file = await tempFile.writeAsBytes(
      byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );

    return file;
  }
}
