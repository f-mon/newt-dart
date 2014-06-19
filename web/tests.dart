
import 'newt/newt.dart';

import 'package:unittest/unittest.dart';
import 'package:event_bus/event_bus.dart';


void main() {

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

    ActivityDisplay display = new ActivityDisplay();
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

    ActivityDisplay display = new ActivityDisplay();
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

    ActivityDisplay display = new ActivityDisplay();
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

    ActivityDisplay display = new ActivityDisplay();
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

      ActivityDisplay display = new ActivityDisplay();
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

      ActivityDisplay display = new ActivityDisplay();
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
