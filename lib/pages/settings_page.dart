import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/IconPack.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:spycamera/widgets/settings_container.dart';

class SettingsRoute extends StatelessWidget {
  String changePath() {
    String result = "czincz";
    return result;
  }

  Future<Icon> changeIcon(context) async {
    IconData icon = await FlutterIconPicker.showIconPicker(context,
        iconPackMode: IconPack.material);

    if(icon == null)
      return null;
    return Icon(icon);
  }

  Future<String> changeDescription(context) async {
    TextEditingController _controller = TextEditingController();
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Setting String"),
          content: TextFormField(
            controller: _controller,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
            )
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: ListTile.divideTiles(context: context, tiles: [
          SettingsContainer(
            icon: Icons.vibration,
            title: "Vibrations after start",
            isSwitch: true,
            switchState: false,
          ),
          SettingsContainer(
            icon: Icons.vibration,
            title: "Vibrations after stop",
            isSwitch: true,
            switchState: false,
          ),
          SettingsContainer(
            icon: Icons.save,
            title: "Saving folder",
            description: "path/path/path",
            onTap: changePath,
          ),
          SettingsContainer(
            icon: Icons.image,
            title: "Notification icon",
            additionalIcon: Icon(Icons.image),
            onTap: changeIcon,
          ),
          SettingsContainer(
            icon: Icons.title,
            title: "Notification title",
            description: "Title",
            onTap: changeDescription,
          ),
          SettingsContainer(
            icon: Icons.description,
            title: "Notification description",
            description: "description",
            onTap: changeDescription,
          ),
        ]).toList(),
      ),
    );
  }
}
