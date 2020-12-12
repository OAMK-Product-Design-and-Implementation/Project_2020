import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:security_control/models/history.dart';
import 'widgets/CreationAwareListItem.dart';
import 'package:stacked/stacked.dart';
import 'batterystation_viewmodel.dart';

class BatteryStationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BatterystationViewModel>.reactive(
      onModelReady: (model) {
        model.initialise();
      },
      builder: (context, model, child) {
        print('BatterystationPage / BatterystationViewModel built');
        return Scaffold(
          appBar: AppBar(
            title: Text(model.title),
          ),
          body: Column(children: [
            StatusSection(),
            LatestSection(),
            Expanded(child: HistorySection()),
          ]),
        );
      },
      viewModelBuilder: () => BatterystationViewModel(),
    );
  }
}

class StatusSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StatusSectionViewModel>.reactive(
      onModelReady: (model) {
        model.listener();
      },
      builder: (context, model, child) {
        print('StatusSectionViewModel built');
        return Card(
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  ListTile(
                    title: Text(model.statusSectionTitle,
                        style: Theme.of(context).textTheme.headline5),
                    trailing: model.status
                        ? Text(
                            'Occupied',
                            style: Theme.of(context).textTheme.headline2,
                          )
                        : Text(
                            'Empty',
                            style: Theme.of(context).textTheme.headline1,
                          ),
                  ),
                  ListTile(
                    title: Text(
                      'Device at station:',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    trailing: model.status
                        ? Text(
                            model.name,
                            style: Theme.of(context).textTheme.headline2,
                          )
                        : Text(
                            '-----',
                            style: Theme.of(context).textTheme.headline1,
                          ),
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

class LatestSection extends StatelessWidget {
  LatestSection({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LatestSectionViewModel>.reactive(
      onModelReady: (model) {
        model.listener();
      },
      builder: (context, model, child) {
        print('LatestSectionViewModel built');
        // print('LatestSection: items.length =${model.items.length}');
        return Card(
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    model.latestSectionTitle,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Divider(),
                  model.recentDevice.id == -5
                      ? CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 18),
                              alignment: Alignment.centerRight,
                              child: Row(
                                children: [
                                  Container(
                                      padding: EdgeInsets.only(right: 4),
                                      child: Icon(CupertinoIcons.clock)),
                                  Text(
                                      timeFormat
                                          .format(model.recentDevice.timestamp),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 30),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 4),
                                      child: Icon(Icons.directions_car_rounded),
                                    ),
                                    Text(model.recentDevice.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        );
      },
      viewModelBuilder: () => LatestSectionViewModel(),
    );
  }
}

class HistorySection extends StatelessWidget {
  HistorySection({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HistorySectionViewModel>.reactive(
        onModelReady: (model) {
          model.listener();
        },
        builder: (context, model, child) {
          print('HistorySection build start');
          // print('HistorySection: items.length =${model.items.length}');
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Text(
                  model.historySectionTitle,
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: model.items.length,
                    itemBuilder: (context, index) => CreationAwareListItem(
                      itemCreated: () {
                        // print('item created $index');
                        SchedulerBinding.instance.addPostFrameCallback(
                            (duration) =>
                                model.handleHistoryItemCreated(index));
                      },
                      child: HistoryItem(
                        device: model.items[index],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        viewModelBuilder: () => HistorySectionViewModel());
  }
}

class HistoryItem extends StatelessWidget {
  final History device;
  const HistoryItem({Key key, this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: device.id == -5
            ? CircularProgressIndicator()
            : Row(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.centerRight,
                    child: Row(children: [
                      Container(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(CupertinoIcons.clock),
                      ),
                      Text(timeFormat.format(device.timestamp)),
                    ]),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 30),
                      child: Row(children: [
                        Container(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.directions_car_rounded),
                        ),
                        Text(device.name),
                      ]),
                    ),
                  ),
                ],
              ),
        alignment: Alignment.center,
      ),
    );
  }
}
