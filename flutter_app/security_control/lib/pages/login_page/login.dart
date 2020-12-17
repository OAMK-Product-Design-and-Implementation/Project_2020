import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'login_viewmodel.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
        viewModelBuilder: () => LoginViewModel(),
        builder: (context, model, child) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.lock,
                        color: Theme.of(context).primaryColor, size: 200),
                    Text(
                      model.title,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Card(
                      margin: EdgeInsets.all(16),
                      color: Theme.of(context).cardColor,
                      child: Container(
                          padding: EdgeInsets.all(16),
                          child: Column(children: <Widget>[
                            TextField(
                              controller: model.userNameController,
                              decoration: InputDecoration(
                                hintText: model.loginFieldHint,
                              ),
                            ),
                            TextField(
                              controller: model.passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: model.passwordFieldHint,
                              ),
                            ),
                            Visibility(
                                visible: model.errorVisible,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding:
                                              EdgeInsets.only(top: 8, left: 8),
                                          child: Text(model.loginDataErrorLabel,
                                              textAlign: TextAlign.left,
                                              textWidthBasis:
                                                  TextWidthBasis.parent,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onError)))
                                    ])),
                            ButtonBar(
                              alignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    model.login();
                                  },
                                  child: Text(model.loginLabel),
                                ),
                                FlatButton(
                                    onPressed: null,
                                    child: Text(model.registerLabel)),
                              ],
                            )
                          ])),
                    ),
                  ],
                ),
              ),
            ));
  }
}
