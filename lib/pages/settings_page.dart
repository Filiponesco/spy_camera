import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spycamera/widgets/settings_container.dart';

class SettingsRoute extends StatelessWidget {
  List<IconData> icons = [
    Icons.access_alarm,
    Icons.print,
    Icons.favorite,
    Icons.description,
    Icons.image,
    Icons.title,
    Icons.save,
    Icons.vibration,
    Icons.done,
    Icons.error,
    Icons.ac_unit,
    Icons.account_box,
    Icons.add_a_photo,
    Icons.add_call,
    Icons.add_comment,
    Icons.airplanemode_active,
    Icons.airplanemode_inactive,
    Icons.airplay,
    Icons.all_inclusive,
    Icons.android,
    Icons.work,
    Icons.wb_sunny,
    Icons.wb_cloudy,
    Icons.volume_up,
    Icons.volume_off,
    Icons.visibility,
    Icons.calendar_today,
    Icons.vertical_align_bottom,
    Icons.usb,
    Icons.tap_and_play,
  ];

  Future<Icon> changeIcon(context, settingName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose icon"),
          content: Container(
            width: 400,
            height: 150,
            child: GridView.count(
              crossAxisCount: 6,
              children: List.generate(icons.length, (i) {
                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: IconButton(
                    icon: Icon(
                      icons[i],
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      prefs.setInt(settingName, icons[i].codePoint);
                      Navigator.pop(context, Icon(icons[i]));
                    },
                  ),
                );
              }),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Future<String> changeDescription(context, settingName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    TextEditingController _controller = TextEditingController();
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Type text"),
          content: TextFormField(
            controller: _controller,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                prefs.setString(settingName, _controller.text);
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
      body: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.data.containsKey('vibration_start'))
              snapshot.data.setBool('vibration_start', false);

            if (!snapshot.data.containsKey('vibration_end'))
              snapshot.data.setBool('vibration_end', false);

            if (!snapshot.data.containsKey('notification_icon'))
              snapshot.data.setInt('notification_icon', 57744);

            if (!snapshot.data.containsKey('notification_title'))
              snapshot.data.setString('notification_title', "Default title");

            if (!snapshot.data.containsKey('notification_description'))
              snapshot.data
                  .setString('notification_description', "Default description");

            return ListView(
              children: ListTile.divideTiles(context: context, tiles: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "Vibration settings",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 22,
                    ),
                  ),
                ),
                SettingsContainer(
                  icon: Icons.vibration,
                  title: "Vibrations after start",
                  isSwitch: true,
                  switchState: snapshot.data.getBool('vibration_start'),
                  settingName: "vibration_start",
                ),
                SettingsContainer(
                  icon: Icons.vibration,
                  title: "Vibrations after end",
                  isSwitch: true,
                  switchState: snapshot.data.getBool('vibration_end'),
                  settingName: "vibration_end",
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Notification settings",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        "You can design your own notification look.\nNotification pops out at the begining of recording.\nClicking on it stops recording.",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                SettingsContainer(
                  icon: Icons.image,
                  title: "Notification icon",
                  additionalIcon: Icon(IconData(
                      snapshot.data.getInt("notification_icon"),
                      fontFamily: 'MaterialIcons')),
                  onTap: changeIcon,
                  settingName: "notification_icon",
                ),
                SettingsContainer(
                  icon: Icons.title,
                  title: "Notification title",
                  description: snapshot.data.getString("notification_title"),
                  onTap: changeDescription,
                  settingName: "notification_title",
                ),
                SettingsContainer(
                  icon: Icons.description,
                  title: "Notification description",
                  description:
                      snapshot.data.getString("notification_description"),
                  onTap: changeDescription,
                  settingName: "notification_description",
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "Information",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 22,
                    ),
                  ),
                ),
                SettingsContainer(
                  icon: Icons.movie,
                  title: "Storage location video",
                  description: "To hide videos, folder is located here:\n /internal/Android/data\n/com.example.spycamera/files\n",
                ),
                SettingsContainer(
                  icon: Icons.info,
                  title: "Authors",
                  description: "Mateusz Adamek, Piotr Białas,\nArkadiusz Datka, Filip Gaweł",
                ),
              ]).toList(),

            );
          } else
            return Center();
        },
      ),
    );
  }
}
