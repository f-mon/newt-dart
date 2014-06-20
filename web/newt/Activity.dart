part of newt;


class Activity {

  static int count = 0;
  
  ActivityManager activityManager;
  Application ownerApp;
  Activity parentActivity;
  
  ActivityDisplay activityDisplay;
  bool isDisplayOwner = false;
  
  Map activityDef;
  String name;
  String instanceId;

  String status = "initial";
  ActivityChannel channel;

  Completer<Activity> loadingCompleter = new Completer<Activity>();
  IFrameElement iframe;

  Activity(this.ownerApp, Map this.activityDef,Activity this.parentActivity, ActivityManager this.activityManager) {
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
      channel.disconnect();
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
      this.iframe = this._createIframe();
    }
    return iframe;
  }
  
  IFrameElement _createIframe() {
    IFrameElement element = new Element.iframe();
    element.classes.add('activityFrame');
    element.attributes['src'] = ownerApp.resolveUrl(this.activityDef['url']);
    element.onLoad.listen((e) {
      _initChannel().then((ch){
          this.channel = ch;
          this.loadingCompleter.complete(this);
      });
    });
    return element;
  }

  Future<ActivityChannel> _initChannel() {
    ActivityChannel ch = new ActivityChannel(this,activityManager.messagesRouter);
    ch.onCommand('executeIntent',_onExecuteIntent);
    return ch.init();
  }
  
  void _onExecuteIntent(Message msg) {    
    var intent = new Intent.fromMessage(msg);
    this.activityManager.intentExecuter.execute(intent).then((r){      
      msg.reply(new Message.create());
    });
  }
  
}

