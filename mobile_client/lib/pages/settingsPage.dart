import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({ Key? key }) : super(key: key);
  static String PATH = "/settings";

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _urlController = TextEditingController();
  TextEditingController _portController = TextEditingController();

  Future<void> _loadSettings() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? url = _prefs.getString("url");
    int? port = _prefs.getInt("port");
    if(url != null && port != null) {
      _urlController.text = url;
      _portController.text = port.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadSettings();
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  label: Text("URL"),
                  hintText: "http://127.0.0.1"
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Please enter an URL';
                  }
                  if(!value.startsWith("http")) {
                    return "URL must start with 'http://' or 'https://'";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _portController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  label: Text("Port"),
                  hintText: "1234",
                ),
                validator: (value) {
                  if(value == null || value.isEmpty || num.tryParse(value) == null) {
                    return 'Please enter the port number';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                child: const Text("Set"),
                onPressed: () async {
                  if(_formKey.currentState!.validate()) {
                    Navigator.pop(
                      context,
                      {
                        "url": _urlController.text,
                        "port": int.parse(_portController.text),
                      }
                    );
                  }
                },
              )
            ],
          )
        ),
      ),
    );
  }
}
