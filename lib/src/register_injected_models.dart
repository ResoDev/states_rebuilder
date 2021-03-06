import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';

///package class used to register and unregister injected models
class RegisterInjectedModel {
  ///package class used to register and unregister injected models
  RegisterInjectedModel(this._injects, this._allRegisteredModelInApp) {
    registerInjectedModels();
  }

  ///List of models registered by one Injector
  final List<Inject<dynamic>> modelRegisteredByThis = <Inject<dynamic>>[];
  final List<Inject<dynamic>> _injects;
  final Map<String, List<Inject<dynamic>>> _allRegisteredModelInApp;

  ///register and injected models (called from the initState of Injector)
  void registerInjectedModels() {
    if (_injects == null || _injects.isEmpty) {
      return;
    }

    for (final Inject<dynamic> inject in _injects) {
      final String name = inject.getName();
      final List<Inject<dynamic>> injectedModels =
          _allRegisteredModelInApp[name];
      if (injectedModels == null) {
        _allRegisteredModelInApp[name] = <Inject<dynamic>>[inject];
      } else {
        _allRegisteredModelInApp[name].add(inject);
      }
      modelRegisteredByThis.add(inject);
    }
  }

  ///Unregister and injected models (called from the dispose of Injector)
  void unRegisterInjectedModels(
    bool disposeModels,
  ) {
    for (final Inject<dynamic> inject in modelRegisteredByThis) {
      final String name = inject.getName();
      final List<Inject<dynamic>> injectedModels =
          _allRegisteredModelInApp[name];

      final bool isRemoved = injectedModels?.remove(inject);

      if (isRemoved && injectedModels.length <= 1) {
        if (disposeModels) {
          try {
            inject.getSingleton()?.dispose();
          } catch (e) {}
        }

        if (inject.isReactiveModel) {
          inject
              .getReactiveSingleton()
              .removeObserver(tag: null, observer: null);
        } else if (inject.isStatesRebuilder) {
          (inject.getSingleton() as StatesRebuilder)
              .removeObserver(tag: null, observer: null);
        }
      }

      if (_allRegisteredModelInApp[name].isEmpty) {
        _allRegisteredModelInApp.remove(name);
      }
    }
  }
}
