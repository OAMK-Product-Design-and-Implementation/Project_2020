import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'settings_viewmodel.dart';
import 'widgets/settings_widgets.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SettingsViewModel>.reactive(
        viewModelBuilder: () => SettingsViewModel(),
        builder: (context, model, child) =>
            Scaffold(
                appBar: AppBar(
                  title: Text(model.appBarLabel),
                ),
                body: Card(
                child:
                  ListView(
                    padding: EdgeInsets.only(top: 8),
                    children: [
                      menuListTile(model.serverSettingsLabel, context, model.openServerSettings),
                      // Divider(),
                      // menuListTile(model.sensorSettingsLabel, context, model.openSensorSettings),
                      Divider(),
                      menuListTile(model.notificationSettingsLabel, context, model.openNotificationSettings),
                      // Divider(),
                      // menuListTile(model.appearanceSettingsLabel, context, model.openAppearanceSettings),
                    ],
                  )
                )
            )
    );
  }
}
