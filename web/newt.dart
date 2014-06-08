import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:unittest/unittest.dart';

void main() {

  test("loadApplication", () {
    var registry = new Registry();
    new ApplicationLoader(registry).load("http://127.0.0.1:3030/newt-dart/web/sampleApp.json").then(expectAsync((Application app) {
      expect(app.name, equals("sampleApp"));
      expect(app.getActivityDef("activityOne"), isNotNull);
    }));

  });


  test("loadStartFirstActivity", () {

    Registry registry = new Registry();
    ApplicationLoader apploader = new ApplicationLoader(registry);
    ActivityManager manager = new ActivityManager(registry);

    apploader.load("http://127.0.0.1:3030/newt-dart/web/sampleApp.json").then(expectAsync((Application app) {
      return manager.startRootActivity("sampleApp", "activityOne");
    })).then(expectAsync((Activity activity) {
      expect(activity.name, equals("activityOne"));
      expect(activity.status, equals("running"));
    }));

  });


}


class ActivityManager {

  Registry registry;
  List<Activity> activityStack = new List();

  ActivityManager(this.registry);


  Future<Activity> startChildActivity(String appName, String activityName) {
    return null;
  }

  Future<Activity> startRootActivity(String appName, String activityName) {
    closeAllActivities();
    return _createAndStartActivity(appName, activityName);
  }

  Future closeAllActivities() {
    if (activityStack.isEmpty) {
      return new Future(() => null);
    }
    return closeActivity().then((d) {
      return closeAllActivities();
    });
  }

  Future closeActivity() {
    if (activityStack.isEmpty) {
      return new Future(() => null);
    } else {
      var currentAct = activityStack.last;
      return currentAct.onClose().then((a) {
        activityStack.remove(currentAct);
      });
    }
  }

  Future<Activity> _createAndStartActivity(String appName, String activityName) {
    Application application = registry.getApplication(appName);
    Map activityDef = application.getActivityDef(activityName);
    Activity newActivity = new Activity(application, activityDef);
    this.activityStack.add(newActivity);
    return newActivity.onStart();
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
      Application app = new Application(appDef);
      registry.registerApp(app);
      return app;
    });
  }

}

class Application {

  Map appDef;
  String name;

  Application(Map this.appDef) {
    this.name = appDef['name'];

  }

  Map getActivityDef(String activityName) {
    List<Map> actDefs = appDef["activities"];
    return actDefs.firstWhere((e) => e['name'] == activityName, orElse: () => null);
  }

}

class Activity {

  static int count = 0;

  Application ownerApp;
  Map activityDef;
  String name;
  String instanceId;

  String status;

  Activity(this.ownerApp, Map this.activityDef) {
    this.name = activityDef['name'];
    this.instanceId = "activity_${Activity.count++}";
  }

  Future<Activity> onStart() {
    return new Future((){
      status = "running";
      return this;
    });
  }

  Future onClose() {
    return new Future(() => null);
  }


}
