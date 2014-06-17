import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:unittest/unittest.dart';
import 'package:event_bus/event_bus.dart';
import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';



void main() {
  
  EventBus eventBus = new EventBus();
  ActivityDisplay display = new ActivityDisplay("activityDisplay");
  Registry registry = new Registry(eventBus);
  ApplicationLoader apploader = new ApplicationLoader(registry);
  ActivityManager manager = new ActivityManager(registry, display);
 
  String appUrl = "http://127.0.0.1:3030/newt-dart/web/apps/sampleApp.json";
  apploader.load(appUrl).then((app){    
     print("load");
  });
  
  Injector injector = applicationFactory()
  .addModule(
    new Module()
      ..bind(EventBus,toValue: eventBus)
      ..bind(ApplicationLoader,toValue: apploader)
      ..bind(ActivityManager,toValue: manager)
      ..bind(NewtToolbarController)
      ..bind(NewtMenuController)
      ..bind(NewtDisplayController)
  )
  .run();
  
}


@Controller(
    selector: '[newt-toolbar]',
    publishAs: 'ctrl')
class NewtToolbarController {
  ActivityManager manager;
  
  NewtToolbarController(ActivityManager this.manager);
  
}

@Controller(
    selector: '[newt-menu]',
    publishAs: 'ctrl')
class NewtMenuController {
  
  List<Application> installedApp;
  EventBus eventBus;
  
  
  NewtMenuController(EventBus this.eventBus) {
    installedApp = new List();
    eventBus.on(installedAppEvent).listen((app) {
      installedApp.add(app);
      print("add");
    });
  }
  
}

@Controller(
    selector: '[newt-display]',
    publishAs: 'ctrl')
class NewtDisplayController {
  ActivityManager manager;
  
  NewtDisplayController(ActivityManager this.manager);
}

void testmain() {

  String appUrl = "http://127.0.0.1:3030/newt-dart/web/apps/sampleApp.json";

  test("loadApplication", () {
    
    EventBus eventBus = new EventBus();
    var registry = new Registry(eventBus);
    new ApplicationLoader(registry).load(appUrl).then(expectAsync((Application app) {
      expect(app.name, equals("sampleApp"));
      expect(app.getActivityDef("activityOne"), isNotNull);
    }));
  });


  test("loadStartFirstActivity", () {

    ActivityDisplay display = new ActivityDisplay("activityDisplay");
    EventBus eventBus = new EventBus();
    Registry registry = new Registry(eventBus);
    ApplicationLoader apploader = new ApplicationLoader(registry);
    ActivityManager manager = new ActivityManager(registry, display);

    apploader.load(appUrl).then(expectAsync((Application app) {
      return manager.startRootActivity("sampleApp", "activityOne");
    })).then(expectAsync((Activity activity) {
      expect(activity.name, equals("activityOne"));
      expect(activity.status, equals("running"));
    }));

  });


  test("loadStartActivityAndClose", () {

    ActivityDisplay display = new ActivityDisplay("activityDisplay");
    EventBus eventBus = new EventBus();
    Registry registry = new Registry(eventBus);
    ApplicationLoader apploader = new ApplicationLoader(registry);
    ActivityManager manager = new ActivityManager(registry, display);

    apploader.load(appUrl).then(expectAsync((Application app) {
      return manager.startRootActivity("sampleApp", "activityOne");
    })).then(expectAsync((Activity activity) {
      expect(activity.name, equals("activityOne"));
      expect(activity.status, equals("running"));
    })).then(expectAsync((Activity activity) {
      return manager.closeAllActivities();
    })).then(expectAsync((Activity activity) {
      expect(manager.activityStack.length, equals(0));
    }));

  });

  test("loadStartChildActivity", () {

    ActivityDisplay display = new ActivityDisplay("activityDisplay");
    EventBus eventBus = new EventBus();
    Registry registry = new Registry(eventBus);
    ApplicationLoader apploader = new ApplicationLoader(registry);
    ActivityManager manager = new ActivityManager(registry, display);

    apploader.load(appUrl).then(expectAsync((Application app) {
      return manager.startRootActivity("sampleApp", "activityOne");
    })).then(expectAsync((Activity activity) {
      expect(manager.activityStack.length, equals(1));
      return manager.startChildActivity("sampleApp", "activityOne");
    })).then(expectAsync((Activity activity) {
      expect(manager.activityStack.first.status, equals("paused"));
      expect(manager.activityStack.last.status, equals("running"));
      expect(manager.activityStack.length, equals(2));
    }));

  });


  test("loadStartChildActivityAndClose", () {

    ActivityDisplay display = new ActivityDisplay("activityDisplay");
    EventBus eventBus = new EventBus();
    Registry registry = new Registry(eventBus);
    ApplicationLoader apploader = new ApplicationLoader(registry);
    ActivityManager manager = new ActivityManager(registry, display);

    apploader.load(appUrl).then(expectAsync((Application app) {
      return manager.startRootActivity("sampleApp", "activityOne");
    })).then(expectAsync((Activity activity) {
      expect(manager.activityStack.length, equals(1));
      return manager.startChildActivity("sampleApp", "activityOne");
    })).then(expectAsync((Activity activity) {
      expect(manager.activityStack.length, equals(2));
      expect(manager.activityStack.first.status, equals("paused"));
      expect(manager.activityStack.last.status, equals("running"));
      return manager.closeActivity();
    })).then(expectAsync((Activity activity) {
      expect(manager.activityStack.length, equals(1));
      expect(manager.activityStack.first.status, equals("running"));
    }));

  });
  
  test("startChildPopupActivity", () {

      ActivityDisplay display = new ActivityDisplay("activityDisplay");
      EventBus eventBus = new EventBus();
      Registry registry = new Registry(eventBus);
      ApplicationLoader apploader = new ApplicationLoader(registry);
      ActivityManager manager = new ActivityManager(registry, display);

      apploader.load(appUrl).then(expectAsync((Application app) {
        return manager.startRootActivity("sampleApp", "activityOne");
      })).then(expectAsync((Activity activity) {
        expect(manager.activityStack.length, equals(1));
        return manager.startChildPopupActivity("sampleApp", "activityOne");
      })).then(expectAsync((Activity activity) {
        expect(activity.activityDisplay, isNot(equals(display)));
        expect(activity.activityDisplay.parentDisplay, equals(display));
      }));

    });
  
  test("startChildPopupActivityAndClosePopup", () {

      ActivityDisplay display = new ActivityDisplay("activityDisplay");
      EventBus eventBus = new EventBus();
      Registry registry = new Registry(eventBus);
      ApplicationLoader apploader = new ApplicationLoader(registry);
      ActivityManager manager = new ActivityManager(registry, display);

      apploader.load(appUrl).then(expectAsync((Application app) {
        return manager.startRootActivity("sampleApp", "activityOne");
      })).then(expectAsync((Activity activity) {
        expect(manager.activityStack.length, equals(1));
        return manager.startChildPopupActivity("sampleApp", "activityOne");
      })).then(expectAsync((Activity activity) {
        expect(activity.activityDisplay, isNot(equals(display)));
        expect(activity.activityDisplay.parentDisplay, equals(display));
      })).then(expectAsync((Activity activity) {
        return manager.closeActivity();
      })).then(expectAsync((Activity activity) {
        expect(manager.activityStack.last.activityDisplay, equals(display));
      }));

    });


}

class ActivityDisplay {

  ActivityDisplay parentDisplay;
  Element element;

  ActivityDisplay(String elementId) {
    this.element = querySelector("#$elementId");
  }
  ActivityDisplay.popupDisplay(ActivityDisplay this.parentDisplay) {
    this.element = new Element.div(); 
  }
  
  showActive(Activity activity) {
    this.element.append(activity.view);
  }

  paused(Activity activity) {
    activity.view.hidden = true;
  }

  resumed(Activity activity) {
    activity.view.hidden = false;
  }

  remove(Activity activity) {
    activity.view.remove();
  }

  ActivityDisplay createPopupDisplay() {
    //TODO put layer on element
    ActivityDisplay popupDisplay = new ActivityDisplay.popupDisplay(this);
    this.element.append(popupDisplay.element);
    return popupDisplay;
  }
  
  void destroyDisplayAndResumeParent() {
    this.element.remove();
  }
  
  bool isRootDisplay() {
    return this.parentDisplay==null;
  }
  
}


class ActivityManager {

  Registry registry;
  ActivityDisplay rootDisplay;

  List<Activity> activityStack = new List();

  ActivityManager(this.registry, this.rootDisplay);


  Future<Activity> startChildActivity(String appName, String activityName) {
    return _startChildActivity(appName, activityName, false);
  }
  
  Future<Activity> startChildPopupActivity(String appName, String activityName) {
    return _startChildActivity(appName, activityName, true);
  }
  
  Future<Activity> _startChildActivity(String appName, String activityName,bool popup) {
    return _pauseCurrentActivity().then((a) {
      return _createAndStartActivity(appName, activityName, a, popup);
    });
  }

  Future<Activity> startRootActivity(String appName, String activityName) {
    closeAllActivities();
    return _createAndStartActivity(appName, activityName, null, false);
  }

  Future closeAllActivities() {
    if (activityStack.isEmpty) {
      return new Future(() => null);
    }
    return closeActivity().then((d) {
      return closeAllActivities();
    });
  }

  Future<Activity> closeActivity() {
    if (activityStack.isEmpty) {
      return new Future(() => null);
    } else {
      var currentAct = activityStack.last;
      return currentAct.onClose().then((a) {
        activityStack.remove(a);
        a.activityDisplay.remove(a);
        if (a.isDisplayOwner) {
          a.activityDisplay.destroyDisplayAndResumeParent();
        }
        return _resumeActivity();
      });
    }
  }

  Future<Activity> _resumeActivity() {
    if (activityStack.isEmpty) {
      return new Future(() => null);
    } else {
      var currentAct = activityStack.last;
      return currentAct.onResume().then((a) {
        a.activityDisplay.resumed(a);
        return a;
      });
    }
  }

  Future<Activity> _pauseCurrentActivity() {
    if (activityStack.isEmpty) {
      return new Future(() => null);
    } else {
      var currentAct = activityStack.last;
      return currentAct.onPause().then((a) {
        a.activityDisplay.paused(a);
        return a;
      });
    }
  }

  Future<Activity> _createAndStartActivity(String appName, String activityName, Activity parentActivity, bool popup) {
    
    Application application = registry.getApplication(appName);
    Map activityDef = application.getActivityDef(activityName);
    Activity newActivity = new Activity(application, activityDef, parentActivity);
    ActivityDisplay parentDisplay = (parentActivity!=null)?parentActivity.activityDisplay:this.rootDisplay;
    
    if (popup) {      
      newActivity.activityDisplay = parentDisplay.createPopupDisplay();
      newActivity.isDisplayOwner = true;
    } else {      
      newActivity.activityDisplay = parentDisplay;
    }
    
    this.activityStack.add(newActivity);
    
    return newActivity.onStart().then((Activity a) {
      a.activityDisplay.showActive(a);
      return a;
    }).then((Activity a) {
      return a.waitLoaded();
    });
  }

}

final EventType<Application> installedAppEvent = new EventType<Application>();

class Registry {
  
  EventBus eventBus;
  Map<String, Application> applications = new Map();

  Registry(EventBus this.eventBus);
  
  registerApp(Application app) {
    if (applications.containsKey(app.name)) {
      throw new Exception("Application with same name (${app.name}) already registered!");
    }
    applications[app.name] = app;
    eventBus.fire(installedAppEvent,app);
  }

  Application getApplication(String appName) {
    return applications[appName];
  }

}


class ApplicationLoader {

  Registry registry;

  ApplicationLoader(Registry this.registry);

  Future<Application> load(String url) {
    return HttpRequest.getString(url).then((json) {
      var appDef = JSON.decode(json);
      Application app = new Application(url, appDef);
      registry.registerApp(app);
      return app;
    });
  }

}

class Application {

  String originUrl;
  Map appDef;
  String name;

  Application(String this.originUrl, Map this.appDef) {
    this.name = appDef['name'];

  }

  Map getActivityDef(String activityName) {
    List<Map> actDefs = appDef["activities"];
    return actDefs.firstWhere((e) => e['name'] == activityName, orElse: () => null);
  }

  String resolveUrl(String path) {
    return originUrl.substring(0, originUrl.lastIndexOf("/")) + "/" + path;
  }
}

class Activity {

  static int count = 0;

  Application ownerApp;
  Activity parentActivity;
  
  ActivityDisplay activityDisplay;
  bool isDisplayOwner = false;
  
  Map activityDef;
  String name;
  String instanceId;

  String status = "initial";

  Completer<Activity> loadingCompleter = new Completer<Activity>();
  Element iframe;

  Activity(this.ownerApp, Map this.activityDef,Activity this.parentActivity) {
    this.name = activityDef['name'];
    this.instanceId = "activity_${Activity.count++}";
  }

  Future<Activity> onStart() {
    return new Future(() {
      status = "running";
      return this;
    });
  }

  Future<Activity> waitLoaded() {
    return loadingCompleter.future;
  }

  Future<Activity> onClose() {
    return new Future(() {
      status = "closed";
      return this;
    });
  }

  Future<Activity> onPause() {
    return new Future(() {
      status = "paused";
      return this;
    });
  }
  
  Future<Activity> onResume() {
      return new Future(() {
        status = "running";
        return this;
      });
    }

  Element get view {
    if (iframe == null) {
      this.iframe = new Element.iframe();
      this.iframe.attributes['src'] = ownerApp.resolveUrl(this.activityDef['url']);
      this.iframe.onLoad.listen((e) {
        loadingCompleter.complete(this);
      });
    }
    return iframe;
  }

}
