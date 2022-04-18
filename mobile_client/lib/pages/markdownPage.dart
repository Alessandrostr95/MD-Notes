import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'markdownEditorPage.dart';

/// `MarkDownPage` renders the markdown file selected by user. 
class MarkDownPage extends StatelessWidget {
  const MarkDownPage({ Key? key}) : super(key: key);
  static String PATH = "/notes";

  void _openEditor() async {

  }

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final path = args["path"];
    final data = args["data"];
    
    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(path)
        ),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Markdown(
          data: data,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.popAndPushNamed(
          context,
          MarkdownEditorPage.PATH,
          arguments: {
            "data": data,
            "path": path,
            "doUpdate": true
          }
        ),
        child: const Icon(Icons.edit),
      ),
    );
  }
}