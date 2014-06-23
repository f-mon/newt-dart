library newt_ui;

import '../newt/newt.dart';
import 'package:event_bus/event_bus.dart';

import 'package:angular/angular.dart' hide Application;
import 'dart:html';

@Controller(
    selector: '[newt-toolbar]',
    publishAs: 'ctrl')
class NewtToolbarController {
  

  EventBus eventBus;
  ActivityManager manager;
  
  NewtToolbarController(Scope scope, ActivityManager this.manager, EventBus this.eventBus) {
    eventBus.on(openedActivityEvent).listen((Activity a) {
      scope.apply();
    });
    eventBus.on(closedActivityEvent).listen((Activity a) {
      scope.apply();
    });
  }
  
  closeActivity() {
    manager.closeActivity();
  }
  
  int get maxBreadcrumbSize {
    return 3;
  }
  
}

@Controller(
    selector: '[newt-menu]',
    publishAs: 'ctrl')
class NewtMenuController {
  
  List<MenuItem> menuItems;
  EventBus eventBus;
  ActivityManager manager;
  
  
  NewtMenuController(ActivityManager this.manager, EventBus this.eventBus) {
    menuItems = new List();
    eventBus.on(installedAppEvent).listen((Application app) {
      for (Map m  in app.activitiesDefs) {
        menuItems.add(new MenuItem()
          ..application= app
          ..activityDef = m
          ..label = m['label']);
      }
    });
  }
  
  select(MenuItem menuItem) {
    manager.startRootActivity(menuItem.application.name,menuItem.activityDef['name']);
  }
  
}


class MenuItem {
  
  String label;
  Application application;
  Map activityDef;
  
}


@Decorator(
    selector: '[newt-display]'
)
class NewtDisplayController {
  
  final Element element;
  
  ActivityManager manager;
  ActivityDisplay rootDisplay;
  
  NewtDisplayController(Element this.element,ActivityManager this.manager,ActivityDisplay this.rootDisplay) {
    element.append(rootDisplay.element);
    element.classes.add("newtRootActivityDisplay");
  }
  
}