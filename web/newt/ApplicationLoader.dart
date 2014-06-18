part of newt;

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