import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// `MarkdownEditorPage` allows the user to edit markdown files.
class MarkdownEditorPage extends StatefulWidget {
  const MarkdownEditorPage({ Key? key }) : super(key: key);
  static String PATH = "/md-editor";

  @override
  State<MarkdownEditorPage> createState() => _MarkdownEditorPageState();
}

class _MarkdownEditorPageState extends State<MarkdownEditorPage> {
  final TextEditingController _controller = TextEditingController();

  /// Dividers symbols for **bold** style
  static const BOLD_SYMBOL = "**";

  /// Dividers symbols for *italic* style
  static const ITALIC_SYMBOL = "*";

  /// Dividers symbols for ~strike~ style
  static const STRIKE_SYMBOL = "~";

  /// Dividers symbols for `code` style
  static const CODE_SYMBOL = "`";

  /// Heading symbol
  static const HEADING_SYMBOL = "#";

  /// Opens an [AlertDialog] that help user to insert an image. 
  void _image() async {

    final result = await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        final imageUrlController = TextEditingController();
        final titleController = TextEditingController();
        final descritpionController = TextEditingController();

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
            content: SizedBox(
              height: MediaQuery.of(context).orientation == Orientation.portrait
              ? MediaQuery.of(context).size.height*.3
              : MediaQuery.of(context).size.height*.9,
              width: MediaQuery.of(context).orientation == Orientation.portrait
              ? MediaQuery.of(context).size.width*.8
              : MediaQuery.of(context).size.width*.6,
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        hintText: "Image url",
                        icon: Icon(Icons.http)
                      ),
                    ),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: "Title",
                        icon: Icon(Icons.title)
                      ),
                    ),
                    TextFormField(
                      controller: descritpionController,
                      decoration: const InputDecoration(
                        hintText: "Description",
                        icon: Icon(Icons.format_quote)
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // title: const Text("Iamge"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop({
                "url": imageUrlController.text,
                "title": titleController.text,
                "description": descritpionController.text
                }),
                child: const Text("OK")
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text("Cancel"),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.red),
                  overlayColor: MaterialStateProperty.all(Colors.red.withAlpha(50)),
                ),
              )
            ],
          ),
        );
      }
    );

    if(result == null) return;

    final String _url = result["url"];
    final String _title = result["title"];
    final String _description = result["description"];

    int start = _controller.selection.start;
    // const _newValue = '\n![Beautiful image](https://www.example.com/image "Title")\n';
    final _newValue = '\n![$_description]($_url "$_title")\n';
    final _oldText = _controller.text;
    _controller.value = TextEditingValue(
      text: _oldText.substring(0, start) + _newValue + _oldText.substring(start),
      selection: TextSelection.fromPosition(
        TextPosition(offset: start + _newValue.length)
      )
    );
  }

  /// Wrap a selected substring into a *link tag*.
  void _link() {
    int start = _controller.selection.start;
    int end = _controller.selection.end;

    final _newValue = "[${_controller.selection.textInside(_controller.text)}](https://www.example.com/)";
    final _oldText = _controller.text;
    _controller.value = TextEditingValue(
      text: _oldText.substring(0, start) + _newValue + _oldText.substring(end),
      selection: TextSelection.fromPosition(
        TextPosition(offset: start + _newValue.length),
      ),
    );
  }

  /// Wrap a selected substring into a given symbol *tag*.
  void _setStyle(String symb){
    int start = _controller.selection.start;
    int end = _controller.selection.end;

    // if (start == end) {
    //   return;
    // }

    final _newValue = symb + _controller.selection.textInside(_controller.text) + symb;
    final _oldText = _controller.text;
    _controller.value = TextEditingValue(
      text: _oldText.substring(0, start) + _newValue + _oldText.substring(end),
      selection: TextSelection.fromPosition(
        TextPosition(offset: start + _newValue.length),
      ),
    );
  }

  /// Insert an *n*-heading in the current cursor position.
  void _setHeading(int n){
    int start = _controller.selection.start;
    final _heads = HEADING_SYMBOL*n + " ";
    final _oldText = _controller.text;
    _controller.value = TextEditingValue(
      text: _oldText.substring(0, start) + _heads + _oldText.substring(start),
      selection: TextSelection.fromPosition(
        TextPosition(offset: start + _heads.length),
      ),
    );
  }
  
  Widget createStyleButton({
    required IconData icon,
    required void Function() onPressed,
    Radius topLeft = Radius.zero,
    Radius topRight = Radius.zero,
    Radius bottomLeft = Radius.zero,
    Radius bottomRight = Radius.zero,
  }) {
    final _borderRadius = BorderRadius.only(
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
    );

    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(),
            borderRadius: _borderRadius
        ),
        child: Icon(icon, color: Colors.black),
      ),
      onTap: onPressed,
      borderRadius: _borderRadius,
    );
  }

  Widget _getTextStyleBar() {
    return Row(
      children: [
        createStyleButton(
          onPressed: () => _setStyle(ITALIC_SYMBOL),
          icon: Icons.format_italic,
          bottomLeft: const Radius.circular(8),
          topLeft: const Radius.circular(8)
        ),
        createStyleButton( 
          onPressed: () => _setStyle(BOLD_SYMBOL),
          icon: Icons.format_bold,
        ),
        createStyleButton(
          onPressed: () => _setStyle(STRIKE_SYMBOL),
          icon: Icons.format_strikethrough,
        ),
        createStyleButton(
          onPressed: () => _setStyle(CODE_SYMBOL),
          icon: Icons.code_outlined,
        ),
        createStyleButton(
          onPressed: () => _link(),
          icon: Icons.link,
        ),
        createStyleButton(
          onPressed: () => _image(),
          icon: Icons.image,
          topRight: const Radius.circular(8),
          bottomRight: const Radius.circular(8)
        ),
      ],
    );
  }

  Widget _getTextHeadingBar() {
    return Row(
      children: [
        createStyleButton(
          onPressed: () => _setHeading(1),
          icon: Icons.looks_one_outlined,
          bottomLeft: const Radius.circular(8),
          topLeft: const Radius.circular(8)
        ),
        createStyleButton( 
          onPressed: () => _setHeading(2),
          icon: Icons.looks_two_outlined,
        ),
        createStyleButton(
          onPressed: () => _setHeading(3),
          icon: Icons.looks_3_outlined,
        ),
        createStyleButton(
          onPressed: () => _setHeading(4),
          icon: Icons.looks_4_outlined,
        ),
        createStyleButton(
          onPressed: () => _setHeading(5),
          icon: Icons.looks_5_outlined,
        ),
        createStyleButton(
          onPressed: () => _setHeading(6),
          icon: Icons.looks_6_outlined,
          topRight: const Radius.circular(8),
          bottomRight: const Radius.circular(8)
        ),
      ],
    );
  }

  /// Async function that read shared preferences.
  /// DA RIMUOVERE PERCHE' RIDONDANTE
  Future<Map> _loadSettings() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? url = _prefs.getString("url");
    int? port = _prefs.getInt("port");
    return {
      "url": url,
      "port": port
    };
  }

  void _onSave({
    required bool doUpdate,
    required String path,
    required String data
  }) async {

    final prefs = await _loadSettings();
    final url = prefs["url"];
    final port = prefs["port"];
    final method = doUpdate ? "update" : "save";
    final _URL = "$url:$port/data/$method";

    http.post(
      Uri.parse(_URL),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode({"path": path, "data": data})
    ).then((value) {
      String msg = "";
      Color c;
      if (value.statusCode == 200) {
        msg = "Saved.";
        c = Colors.green;
      } else {
        msg = "Ops, I can't save now! Try later.";
        c = Colors.orange;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: c,
          dismissDirection: DismissDirection.horizontal,
          behavior: SnackBarBehavior.floating,
          elevation: 20,
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final path = args["path"];
    final data = args["data"];
    final bool doUpdate = args["doUpdate"];
    _controller.text = data;

    return Scaffold(

      appBar: AppBar(
        title: Text(path),
        automaticallyImplyLeading: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _getTextStyleBar()
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.h_mobiledata),
                        _getTextHeadingBar(),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _controller,
                enableInteractiveSelection: true,
                expands: true,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _onSave(doUpdate: doUpdate, path: path, data: _controller.text),
        child: const Icon(Icons.save),
      ),
    );
  }
}