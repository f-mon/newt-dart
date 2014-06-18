part of newt;

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
  
  List<Map> get activitiesDefs => appDef["activities"];
  
}

