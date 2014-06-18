part of newt;


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
