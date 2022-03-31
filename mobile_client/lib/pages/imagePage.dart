import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// `ImagePage` renders the image file selected by user. 
class ImagePage extends StatelessWidget {
  const ImagePage({ Key? key }) : super(key: key);
  static String PATH = "/image";

  @override
  Widget build(BuildContext context) {

    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final String _uri = args["uri"];

    return SafeArea(
      child: PhotoView(
        imageProvider: NetworkImage(_uri),
      ),
    );
  }
}