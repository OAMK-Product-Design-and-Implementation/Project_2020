import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'subsettings_viewmodel.dart';
import 'widgets/settings_widgets.dart';

class NotificationSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SubSettingsViewModel>.reactive(
        viewModelBuilder: () => SubSettingsViewModel(),
        builder: (context, model, child) =>
            Scaffold(
                appBar: AppBar(
                  title: Text(model.notificationSettingsLabel),
                ),
                body: Card(
                    child:
                    ListView(
                      padding: EdgeInsets.only(top: 8),
                      children: [
                        menuSwitchListTile(model.receiveNotificationsLabel, context, model.receiveNotifications, model.setReceiveNotifications, true),
                        Divider(),
                        menuSwitchListTile(model.intruderAlertsLabel, context, model.receiveIntruderAlerts, model.setReceiveIntruderAlerts, model.receiveNotifications),
                        menuSwitchListTile(model.lowBatteryAlertsLabel, context, model.receiveLowBatteryAlerts, model.setReceiveLowBatteryAlerts, model.receiveNotifications),
                      ],
                    )
                )
            )
    );
  }
}