import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget menuListTile(String title, BuildContext context, Function action,
    [String subtitle]) {
  return new ListTile(
    title: Text(
      title,
      style: Theme.of(context)
          .textTheme
          .button
          .copyWith(fontSize: 18, fontWeight: FontWeight.normal),
    ),
    onTap: action,
    subtitle: subtitle == null ? null : Text(subtitle),
  );
}

// Action function must take double as parameter: action(value)
Widget menuSwitchListTile(
  String title,
  BuildContext context,
  valueToFollow,
  Function action,
  bool enabled,
) {
  return new SwitchListTile(
      title: Text(title,
          style: Theme.of(context).textTheme.button.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              )),
      value: valueToFollow,
      onChanged: !enabled
          ? null
          : (bool value) {
              action(value);
            });
}

// Action function must take double as parameter: action(value)
Widget menuSliderListItem(
  String title,
  BuildContext context,
  Function action,
  double valueToFollow,
  double maxValue,
  double minValue,
    [Function actionOnRelease]
) {
  return new Padding(
      padding: EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.max, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.button.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ))
          ],
        ),
        Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(valueToFollow.round().toString() + 's'),
                  Expanded(
                    child: Slider(
                        value: valueToFollow,
                        max: maxValue,
                        min: minValue,
                        label: valueToFollow.round().toString(),
                        onChanged: (double value) {
                          action(value);
                        },
                        onChangeEnd: actionOnRelease == null ? null : actionOnRelease,  // if action defined, call it
                    ),

                  ),
                ]))
      ]));
}

Widget requestTextAlertDialog(
    BuildContext context,
    String title,
    String hint,
    String confirmButtonLabel,
    String cancelButtonLabel,
    Function confirmAction,
    TextEditingController textController) {
  return new AlertDialog(
    title: Text(title),
    content: SingleChildScrollView(
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
        ),
        controller: textController,
      ),
    ),
    actions: [
      FlatButton(onPressed: (){confirmAction();Navigator.of(context).pop();}, child: Text(confirmButtonLabel)),
      FlatButton(onPressed: (){Navigator.of(context).pop();}, child: Text(cancelButtonLabel))
    ],
  );
}

