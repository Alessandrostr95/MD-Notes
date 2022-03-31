import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

/// Given a JsonString, returns a tree of `Node` objects.\\
/// It works recursively.
List<Node> jsonString2nodesTree(String json){
  final List tree = jsonDecode(json);

  return List<Node>.generate(tree.length, (index) {
    final _node = tree[index];
    return Node(
      key: _node["key"],
      label: _node["label"],
      icon: _node["type"] == "directory" ? Icons.folder : _getIconFromExtension(_node["extension"]),
      parent: _node["parent"],
      children: _node["children"] != null ? jsonString2nodesTree(jsonEncode(_node["children"])) : [],
      iconColor: _node["type"] == "directory" ? Colors.blue : Colors.black54,
      data: _node["type"] == "file"
      ?{
        "extension": _node["extension"],
        "size": _node["size"],
        "path": _node["path"]
      }
      : null,
    );
  }).toList();
}

// Return the icon in according to a giveng *extension*.
IconData? _getIconFromExtension(String extension) {
  switch (extension) {
    case ".png":
      return Icons.image;
    case ".jpg":
      return Icons.image;
    case ".md":
      return Icons.text_snippet_rounded;
    default:
      return null;
  }
}

const String URL = "http://10.0.2.2:7867";