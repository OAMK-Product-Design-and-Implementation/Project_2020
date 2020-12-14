import 'package:flutter/material.dart';
import 'drifters_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:animations/animations.dart';
import 'widgets/drifters_widgets.dart';

class DriftersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DriftersViewModel>.reactive(
      builder: (context, model, child) {
        print('DriftersPage / DriftersViewModel built');
        return Scaffold(
          appBar: AppBar(
            title: Text(model.title),
          ),
          body: ListView(
            children: [
              MapSection(),
              StatusSection(),
            ],
          ),
        );
      },
      viewModelBuilder: () => DriftersViewModel(),
    );
  }
}

class MapSection extends StatelessWidget {
  MapSection({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        onModelReady: (model) {
          model.listener();
        },
        builder: (context, model, child) {
          print('MapSection built');
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(model.map),
                  ),
                ),
                Container(
                  //temp animate car2
                  child: AnimatedAlign(
                      curve: Curves.fastOutSlowIn,
                      duration: Duration(milliseconds: 500),
                      alignment: model.location['2'],
                      child: Icon(
                        Icons.local_taxi,
                        size: 26,
                      )),
                ),
                for (var item in model.gopigolist)
                  //check not loading element
                  if (item.id != -5) mapIconPlacer(context, model, item),
              ],
            ),
          );
        },
        viewModelBuilder: () => MapSectionViewModel());
  }
}

class StatusSection extends StatelessWidget {
  StatusSection({Key key}) : super(key: key);
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
                  Text(
                    model.statusSectionTitle,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  for (var i in model.gopigolist)
                    Column(
                      children: [
                        Divider(),
                        i.id == -5
                            ? CircularProgressIndicator()
                            : gopigoListTileAnimated(context, i, model),
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
