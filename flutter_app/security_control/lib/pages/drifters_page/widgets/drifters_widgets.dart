import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../drifters_viewmodel.dart';

Widget mapIconPlacer(context, model, device) {
  return Container(
    child: AnimatedAlign(
        curve: Curves.fastOutSlowIn,
        duration: Duration(milliseconds: 500),
        alignment: model?.location[device?.location] ?? model.location['lost'],
        child: Icon(
          Icons.local_taxi,
          size: 26,
        )),
  );
}

Widget gopigoListTileAnimated(context, device, model) {
  print('gopigoListTileAnimated: [${device.name}] section built');
  return OpenContainer(
    transitionType: ContainerTransitionType.fade,
    closedElevation: 0.0,
    closedColor: Theme.of(context).cardColor,
    closedBuilder: (BuildContext _, VoidCallback openContainer) {
      return ListTile(
        leading: Icon(
          Icons.directions_car_rounded,
        ),
        title: Text(
          device.name,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        trailing: Container(
          //icon sizes adjusted to match material design
          width: 58,
          height: 48,
          padding: EdgeInsets.symmetric(vertical: 4.0),
          alignment: Alignment.center,
          child: Row(
            children: [
              Icon(
                Icons.battery_std,
              ),
              device.batterylevel.current == 404
                  ? Text(
                      '--',
                      style: Theme.of(context).textTheme.bodyText2,
                    )
                  : Text(
                      device.batterylevel.current.round().toString() + '%',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
            ],
          ),
        ),
        onTap: openContainer,
      );
    },
    openBuilder: (BuildContext _, VoidCallback openContainer) {
      //new viewmodel so we don't rebuild the whole page
      //before final settings are approved
      return ViewModelBuilder<GoPiGoSettingsViewModel>.reactive(
        initialiseSpecialViewModelsOnce: true,
        builder: (context, model, child) {
          if (device.id != model.id) model.setdevice(device);
          print(
              'GoPiGoSettingsViewModel for [${device.name}]/[${model.name}] built');
          return Scaffold(
            appBar: AppBar(
              title: Text('${device.name} - Settings'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.done),
                  onPressed: () {
                    model.updateSettings();
                    Navigator.pop(context, true);
                  },
                  tooltip: 'Mark as done',
                )
              ],
            ),
            body: ListView(children: [
              Card(
                child: Container(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            helperText: 'device.name',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: model.name,
                          onChanged: (String value) {
                            model.nameTextUpdate(value);
                          },
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Text('Battery limit (%)'),
                        subtitle: model.batterySlider(context, device),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          );
        },
        viewModelBuilder: () => GoPiGoSettingsViewModel(),
      );
    },
  );
}
