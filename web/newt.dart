import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:unittest/unittest.dart';

void main() {

  String appUrl = "http://127.0.0.1:3030/newt-dart/web/apps/sampleApp.json";

  test("loadApplication", () {
    
    var registry = new Registry();
    new ApplicationLoader(registry).load(appUrl).then(expectAsync((Application app) {
      expect(app.name, equals("sampleApp"));
      expect(app.getActivityDef("activityOne"), isNotNull);
    }));
  });


  test("loadStartFirstActivity", () {

    ActivityDisplay display = new ActivityDisplay("activityDisplay");
    Registry registry = new Registry();
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
    Registry registry = new Registry();
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
    Registry registry = new Registry();
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
    Registry registry = new Registry();
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


}

class ActivityDisplay {

  Element element;

  ActivityDisplay(String elementId) {
    this.element = querySelector("#$elementId");
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

}


class ActivityManager {

  Registry registry;
  ActivityDisplay display;

  List<Activity> activityStack = new List();

  ActivityManager(this.registry, this.display);


  Future<Activity> startChildActivity(String appName, String activityName) {
    return _startChildActivity(appName, activityName, false);
  }
  
  Future<Activity> startChildPopupActivity(String appName, String activityName) {
    return _startChildActivity(appName, activityName, true);
  }
  
  Future<Activity> _startChildActivity(String appName, String activityName,bool popup) {
    return _pauseCurrentActivity().then((a) {
      return _createAndStartActivity(appName, activityName, a);
    });
  }

  Future<Activity> startRootActivity(String appName, String activityName) {
    closeAllActivities();
    return _createAndStartActivity(appName, activityName, null);
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
        display.remove(a);
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
        display.resumed(a);
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
        display.paused(a);
        return a;
      });
    }
  }

  Future<Activity> _createAndStartActivity(String appName, String activityName, Activity parentActivity) {
    Application application = registry.getApplication(appName);
    Map activityDef = application.getActivityDef(activityName);
    Activity newActivity = new Activity(application, activityDef, parentActivity);
    this.activityStack.add(newActivity);
    return newActivity.onStart().then((Activity act) {
      display.showActive(act);
      return act;
    }).then((Activity act) {
      return act.waitLoaded();
    });
  }

}



class Registry {

  Map<String, Application> applications = new Map();

  registerApp(Application app) {
    if (applications.containsKey(app.name)) {
      throw new Exception("Application with same name (${app.name}) already registered!");
    }
    applications[app.name] = app;
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
