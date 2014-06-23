
import 'newt/newt.dart';
import 'newt_ui/newt_ui.dart';

import 'package:event_bus/event_bus.dart';
import 'package:angular/angular.dart' hide Application;
import 'package:angular/application_factory.dart';



void main() {
  
  EventBus eventBus = new EventBus();
  ActivityDisplay display = new ActivityDisplay();
  Registry registry = new Registry(eventBus);
  ApplicationLoader apploader = new ApplicationLoader(registry);
  ActivityManager manager = new ActivityManager(eventBus,registry, display);
 
  String appUrl = "http://127.0.0.1:3030/newt-dart/web/apps/sampleApp.json";
  apploader.load(appUrl);
  
  Injector injector = applicationFactory()
  .addModule(
    new Module()
      ..bind(EventBus,toValue: eventBus)
      ..bind(ActivityDisplay,toValue: display)
      ..bind(ApplicationLoader,toValue: apploader)
      ..bind(ActivityManager,toValue: manager)
      ..bind(NewtToolbarController)
      ..bind(NewtMenuController)
      ..bind(NewtDisplayController)
  )
  .run(); 
}

