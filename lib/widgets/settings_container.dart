import 'package:flutter/material.dart';

class SettingsContainer extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSwitch;
  final bool switchState;
  final Icon additionalIcon;
  final Function onTap;

  SettingsContainer(
      {Key key,
      this.icon,
      this.title,
      this.description,
      this.isSwitch = false,
      this.switchState,
      this.additionalIcon,
      this.onTap})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingsContainerState();
  }
}

class _SettingsContainerState extends State<SettingsContainer> {
  bool _switch;
  String _desc;
  Widget _additionalIcon;

  void switchStateChanged(bool state) {
    setState(() {
      _switch = state;
    });
  }

  void descriptionChanged() async {
    var result = await widget.onTap(context);
    setState(() {
      if (result is String && result.length > 0)
        _desc = result;
      else if (result is Icon)
        _additionalIcon = result;
    });
  }

  @override
  void initState() {
    _switch = widget.switchState;
    _desc = widget.description;
    _additionalIcon = widget.additionalIcon;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (widget.onTap != null)
          descriptionChanged();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  widget.icon,
                  size: 30,
                  color: Colors.orange,
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.description != null)
                      Text(
                        _desc,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (widget.isSwitch)
              Switch(
                value: _switch,
                onChanged: (bool state) {
                  switchStateChanged(state);
                },
              ),
            if (widget.additionalIcon != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _additionalIcon,
              ),
          ],
        ),
      ),
    );
  }
}
