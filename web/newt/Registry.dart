part of newt;


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

