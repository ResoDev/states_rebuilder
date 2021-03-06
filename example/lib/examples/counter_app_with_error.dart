import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Counter {
  int _count = 0;
  int get count => _count;
  Future<void> increment() async {
    //Simulating async task
    await Future<void>.delayed(const Duration(seconds: 1));
    //Simulating error (50% chance of error);
    final bool isError = Random().nextBool();

    if (isError) {
      throw Exception('A fake network Error');
    }
    _count++;
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<Counter>(() => Counter())],
      builder: (BuildContext context) {
        final ReactiveModel<Counter> counterModel =
            Injector.getAsReactive<Counter>();
        return Scaffold(
          appBar: AppBar(
            title: const Text(' Counter App With error'),
          ),
          body: MyHome(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => counterModel.setState(
              (Counter state) => state.increment(),
              catchError: true, //catch the error
              onSetState: (BuildContext context) {
                // osSetState will be executed after mutating the state.
                if (counterModel.hasError) {
                  showDialog<dynamic>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Error!'),
                      content: Text('${counterModel.error}'),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('You have 50% chance of error'),
          StateBuilder<Counter>(
            models: [Injector.getAsReactive<Counter>()],
            onSetState: (context, counterModel) {
              print("1- onSetState");
            },
            onRebuildState: (context, counterModel) {
              print("3- onRebuildState");
            },
            builder: (BuildContext context, counterModel) {
              print("2- build");

              if (counterModel.isWaiting) {
                return const CircularProgressIndicator();
              }

              return Text(
                '${counterModel.state.count}',
                style: const TextStyle(fontSize: 50),
              );
            },
          ),
        ],
      ),
    );
  }
}
