import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:animations/animations.dart';
import 'sensors_viewmodel.dart';

class SensorsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SensorsViewModel>.reactive(
      builder: (context, model, child) {
        print('SensorsPage / SensorsViewModel built');
        return Scaffold(
          appBar: AppBar(
            title: Text(model.title),
          ),
          body: Container(
            padding: EdgeInsets.all(8),
            child: StatusSection(),
          ),
        );
      },
      viewModelBuilder: () => SensorsViewModel(),
    );
  }
}

class StatusSection extends StatelessWidget {
  StatusSection({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StatusSectionViewModel>.reactive(
      onModelReady: (model) {
        model.initialise();
      },
      builder: (context, model, child) {
        print('StatusSectionViewModel built');
        return Card(
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: ListView(
                children: [
                  Text(
                    model.statusSectionTitle,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  for (var i in model.ruuvitaglist)
                    Column(
                      children: [
                        Divider(),
                        _ruuvitagListTileAnimated(context, i, model),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
      viewModelBuilder: () => StatusSectionViewModel(),
    );
  }
}

Widget _ruuvitagListTileAnimated(context, device, model) {
  print('[${device.name}] section built in _ruuvitagListTileAnimated');
  return OpenContainer(
    transitionType: ContainerTransitionType.fade,
    closedElevation: 0.0,
    closedColor: Theme.of(context).cardColor,
    closedBuilder: (BuildContext _, VoidCallback openContainer) {
      return Container(
        child: Column(
          children: [
            Row(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(CupertinoIcons.snow),
                    Text(
                      device.name,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
                Expanded(
                  child: Text(
                    device.status(),
                    style: device.status() != true
                        ? TextStyle(color: Theme.of(context).primaryColor)
                        : TextStyle(color: Theme.of(context).accentColor),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(height: 48, child: Icon(Icons.battery_std)),
                Text(device.batterylevel.current.toString() + ' %'),
                Container(
                    height: 48,
                    margin: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.thermometer)),
                Text(device.temperature.current.toString() + ' C'),
                Container(
                    margin: EdgeInsets.only(left: 8),
                    height: 48,
                    child: Icon(CupertinoIcons.tornado)),
                Text(device.pressure.current.toString() + ' hPa'),
                Container(
                    margin: EdgeInsets.only(left: 8),
                    height: 48,
                    child: Icon(CupertinoIcons.gauge)),
                Text(device.humidity.current.toString() + ' %'),
              ],
            ),
          ],
        ),
      );
    },
    openBuilder: (BuildContext _, VoidCallback openContainer) {
      //new viewmodel so we don't rebuild the whole page
      //before final settings are approved
      return ViewModelBuilder<RuuviTagSettingsViewModel>.reactive(
        initialiseSpecialViewModelsOnce: true,
        builder: (context, model, child) {
          if (device.id != model.id) model.setdevice(device);
          print(
              'RuuviTagSettingsViewModel for [${device.name}]/[${model.name}] built');
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
                            labelText: 'Name',
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
                        isThreeLine: true,
                        title: Text('Battery limit (%)'),
                        subtitle: model.batterySlider(context, device),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Temperature limits (°C)'),
                        subtitle: model.temperatureRangeSlider(context, device),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Humidity limit (%)'),
                        subtitle: model.humidityRangeSlider(context, device),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Airpressure limit (hPa)'),
                        subtitle: model.pressureRangeSlider(context, device),
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ),
            ]),
          );
        },
        viewModelBuilder: () => RuuviTagSettingsViewModel(),
      );
    },
  );
}
