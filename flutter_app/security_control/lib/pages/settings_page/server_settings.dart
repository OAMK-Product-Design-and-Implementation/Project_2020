import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'subsettings_viewmodel.dart';
import 'widgets/settings_widgets.dart';

class ServerSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SubSettingsViewModel>.reactive(
        onModelReady: (model) => model.initialise(),
        viewModelBuilder: () => SubSettingsViewModel(),
        builder: (context, model, child) => Scaffold(
            appBar: AppBar(
              title: Text(model.serverSettingsLabel),
            ),
            body: Card(
                child: ListView(
              padding: EdgeInsets.only(top: 8),
              children: [
                serverAddressTileAnimated(context, model),
                Divider(),
                menuSliderListItem(
                    model.serverUpdateIntervalLabel,
                    context,
                    model.setServerUpdateInterval,
                    model.serverUpdateInterval,
                    model.maxServerUpdateInterval,
                    model.minServerUpdateInterval,
                    model),
              ],
            ))));
  }
}

Widget serverAddressTileAnimated(context, model) {
  return ListTile(
      title: Text(model.serverAddressLabel),
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => requestTextAlertDialog(
                context,
                model.serverAddressDialogTitle,
                model.serverAddressDialogHintLabel,
                model.serverAddressDialogConfirmButtonLabel,
                model.serverAddressDialogCancelButtonLabel,
                model.setServerAddress,
                model.serverAddressEditingController));
      },
      subtitle: Text(model.serverAddress));
}
