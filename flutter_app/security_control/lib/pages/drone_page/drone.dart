import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:stacked/stacked.dart';
import 'drone_viewmodel.dart';
import 'package:latlong/latlong.dart';

class DronePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DroneViewModel>.reactive(
        viewModelBuilder: () => DroneViewModel(),
        builder: (context, model, child) => Scaffold(
            appBar: AppBar(title: Text(model.appBarTitle)),
            body: Column(children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(model.droneConnectionLabel,
                          style: Theme.of(context).textTheme.headline6),
                      trailing: model.droneConnected == true
                          ? Text(
                              model.droneOnlineText,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: model.labelFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              model.droneOfflineText,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: model.labelFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    ListTile(
                      title: Text(model.droneStatusLabel,
                          style: Theme.of(context).textTheme.headline6),
                      trailing: model.droneConnected == true
                          ? Text(
                              model.droneStatusText,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: model.labelFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              model.droneStatusText,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: model.labelFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              _mapSection(),
              Card(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                      title: Text(model.droneControlHeadline,
                          style: Theme.of(context).textTheme.headline6)),
                  Divider(),
                  ButtonBar(
                    mainAxisSize: MainAxisSize.max,
                    layoutBehavior: ButtonBarLayoutBehavior.padded,
                    alignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: model.sendGoHome,
                        style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(Size(150, 2))),
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(model.goHomeLabel)),
                      ),
                      ElevatedButton(
                        onPressed: model.sendStartPatrol,
                        style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(Size(150, 2))),
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(model.startPatrolLabel)),
                      ),
                    ],
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: model.sendEmergencyStop,
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).accentColor),
                        child: Text(model.emergencyStopLabel),
                      ),
                    ],
                  )
                ],
              )),
            ])));
  }
}


Widget _mapSection() {
  return Card(
    clipBehavior: Clip.antiAlias,
    child: SizedBox(
      //TODO make this dynamic size for bigger/smaller screens
      height: 300.0,
      // width: 350.0,
      child: Stack(
        children: [
          new FlutterMap(
            options: new MapOptions(
              center: new LatLng(65.059029, 25.466243),
              zoom: 15.0,
            ),
            layers: [
              new TileLayerOptions(
                  urlTemplate:
                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              new MarkerLayerOptions(
                markers: [
                  new Marker(
                    width: 26.0,
                    height: 26.0,
                    point: LatLng(65.058998, 25.462000),
                    builder: (ctx) => new Container(
                      child: Icon(Icons.api, color: Colors.red,size: 36,),
                    ),
                  )
                ],
              ),
            ],
            children: <Widget>[
              TileLayerWidget(
                  options: TileLayerOptions(
                      urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'])),
              MarkerLayerWidget(
                  options: MarkerLayerOptions(
                    markers: [
                      Marker(
                        width: 26.0,
                        height: 26.0,
                        point: LatLng(65.058998, 25.461282),
                        builder: (ctx) => Container(
                          child: FlutterLogo(),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: Column(
          //     children: [
          //       SizedBox(
          //         height: 32.0,
          //         child: Card(
          //           //color: Theme.of(context).backgroundColor,
          //           child: Container(
          //             //padding: const EdgeInsets.all(8),
          //             child: Text('Map Section goes Here',)
          //                 // style: Theme.of(context).textTheme.headline6),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    ),
  );
}