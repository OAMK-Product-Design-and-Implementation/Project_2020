import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'drifters_viewmodel.dart';
import 'widgets/drifters_widgets.dart';

class DriftersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DriftersViewModel>.reactive(
      onModelReady: (model) {
        model.initalise();
      },
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
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(child: Image.asset(model.map)),
                  ),
                  for (var item in model.gopigolist)
                    //check not loading element
                    if (item.id != -5) mapIconPlacer(context, model, item),
                ],
              ),
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
