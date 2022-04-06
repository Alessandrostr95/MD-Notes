// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_client/pages/settingsPage.dart';
import 'markdownPage.dart';
import 'imagePage.dart';
import '../utility.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Home page of application.\
/// Load the data from server, and shows the tree directory.
/// 
/// Selecting the folder nodes, they will collapse or expands.\
/// Selecting files, the application will renderes them in a new page.
/// 
/// It is also possible to:
/// - re-fetch data.
/// - change settings of server interface (url and port).
/// - toggle dark and light theme.
/// 
/// Supported file extensions are:
/// - `.md`
/// - `.png`
/// - `.jpg`
/// 
/// New file supports and features will come soon.
class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _dark = false;

  late TreeViewController _treeViewController;
  String? _selectedNode;

  /// Initialize state of HomePage.
  /// First initialize the `_treeViewController` variable, than start to fetch data.
  @override
  void initState() {
    _treeViewController = TreeViewController();
    _fetchData();
    super.initState();
  }

  /// Async function that read shared preferences.
  Future<Map> _loadSettings() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? url = _prefs.getString("url");
    int? port = _prefs.getInt("port");
    return {
      "url": url,
      "port": port
    };
  }

  /// Async function that write shared preferences.
  Future<void> _updateSettings(String url, int port) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("url", url);
    _prefs.setInt("port", port);
  }

  /// Async function that fetch data from server.\
  /// First try to load *shared preferences*.\
  /// If they don't exist, than open **SettingsPage** to set `url` and `port` of server service.
  /// 
  /// When data fetched, set the new `_treeViewController`.\
  /// After 5 seconds, displays a **SnackBar** notifying the user that the server is probabily down.
  /// If errors occur, shows a **SnackBar** notification of error.
  Future<void> _fetchData() async {
    final _loadedData = await _loadSettings();
    String? url = _loadedData["url"];
    int? port = _loadedData["port"];

    if(url == null || port == null) {
      final data = await Navigator.pushNamed(context, SettingsPage.PATH) as Map;
      url = data["url"];
      port = data["port"];
      _updateSettings(url!, port!);
    }
    final _URL = "$url:$port";

    await http.get(Uri.parse("$_URL/data")).then((value) {
      print("BODY -> ${value.body}");
      setState(() {
        // _treeViewController = _treeViewController.loadJSON(json: value.body);
        _treeViewController = _treeViewController.copyWith(children: jsonString2nodesTree(value.body));
      });
    }).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        _errorNotification(
          msg: "Waiting time too long. The server might be down, unreachable or bad.",
          backgroundColor: Colors.orange
        );
      }
    ).onError((error, stackTrace) {
      // quando chiama il timeout dopo un po' richiama anche l'errore se accade
      _errorNotification();
    });
  }

  /// Shows a snackbar that notify an error message.
  void _errorNotification({
    String msg = "Ops! Something went wrong. Try later...",
    Color backgroundColor = Colors.red
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: backgroundColor,
        dismissDirection: DismissDirection.horizontal,
        behavior: SnackBarBehavior.floating,
        elevation: 20,
      )
    );
  }

  /// Handler for node tapping.
  /// 
  /// First set the current selected node.\
  /// Than opern a new page showing the file selected, depending of the file *extension*.
  /// 
  /// Currently file types supported:
  /// - `.md`
  /// - `.png`
  /// - `.jpg`
  void _onNodeTap(String key) async {
    print("Node tapped -> $key");
    _selectedNode = key;
    setState(() {
      _treeViewController = _treeViewController.copyWith(selectedKey: _selectedNode);
    });
    final _node = _treeViewController.getNode(key);
    // final _path = _node!.key.substring(1);
    final String _path = _node!.data["path"].substring(5);
    final String _extension =_node.data["extension"];

    final _loadedData = await _loadSettings();
    String? url = _loadedData["url"];
    int? port = _loadedData["port"];
    final _URL = "${url!}:${port!}";

    if(_extension == ".md"){
      //http.get(Uri.parse("http://localhost:7867/api/v1/data/?path=$_path")).then((value) {
      http.get(Uri.parse("$_URL/$_path")).then((value) {
        // print("get -> ${value.body}");
        Navigator.pushNamed(
          context,
          MarkDownPage.PATH,
          arguments: {
            "path": _path,
            // "data": jsonDecode(value.body)["data"]
            "data": value.body
          }
        );
      });
    } else if(_extension == ".png" || _extension == ".jpg") {
      Navigator.pushNamed(
        context,
        ImagePage.PATH,
        arguments: {"uri": "$_URL/$_path"}
      );
    }
  }

  /// Handler thath expands the *directory* nodes when tapped, toggling *closed* and *opened* folder icon. 
  void _expandNode(String key, bool expanded) {
    Node _node = _treeViewController.getNode(key)!;
    setState(() {
      List<Node> _newNodes = _treeViewController.updateNode(
        key,
        _node.copyWith(
          expanded: expanded,
          icon: expanded ? Icons.folder_open : Icons.folder,
        )
      );
      _treeViewController = _treeViewController.copyWith(children: _newNodes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _treeTheme = TreeViewTheme(
      colorScheme: Theme.of(context).colorScheme
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: !_dark? Colors.white60: null,
        actions: [
          IconButton(onPressed: _fetchData, icon: const Icon(Icons.get_app)),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final data = await Navigator.pushNamed(context, SettingsPage.PATH) as Map;
              String url = data["url"];
              int port = data["port"];
              await _updateSettings(url, port);
              await _fetchData();
            },
          )
        ],
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          child: TreeView(
            controller: _treeViewController,
            allowParentSelect: false,
            onExpansionChanged: _expandNode,
            onNodeTap: _onNodeTap,
            theme: _treeTheme,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: !_dark ? Colors.black54: Colors.white70,
        child: _dark ? const Icon(Icons.light_mode,) : const Icon(Icons.dark_mode, color: Colors.white70),
        elevation: 12,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onPressed: () {
          if(!_dark){
            AdaptiveTheme.of(context).setDark();
          } else {
            AdaptiveTheme.of(context).setLight();
          }
          setState(() {
            _dark = !_dark;
          });
        },
      ),
    );
  }
}