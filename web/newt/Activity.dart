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
      element.contentWindow.postMessage({
        'eventName':'initialize',
        'instanceId':instanceId
      },"*");
      loadingCompleter.complete(this);
    });
    return element;
  }

  Future<ActivityChannel> _initChannel() {
    ActivityChannel ch = new ActivityChannel(this,activityManager.messagesRouter);
    ch.onCommand('executeIntent',(Message msg) {
      print(msg);
      msg.reply(new Message.create());
    });
    return ch.init();
  }
  
}

class ActivityChannel {
  
  final Activity activity;
  final MessagesRouter router;
  Completer<ActivityChannel> channelInitCompleter;
  final Map<String,CommandHandler> commandHandlers = new Map();
  
  ActivityChannel(this.activity,this.router) {
    this.router.connectChannel(this);
  }
  
  Future<ActivityChannel> init() {
    channelInitCompleter = new Completer<ActivityChannel>();
    activity.iframe.contentWindow.postMessage({
      'commandName':'initialize',
      'instanceId':activity.instanceId
    },"*");
    return channelInitCompleter.future;
  }
  
  void notifyMessage(Message msg) {
    String commandName = msg.commandName;
    if ("initialized"==commandName) {
      channelInitCompleter.complete(this);
    } else {
      var commandHandler = commandHandlers[commandName];
      if (commandHandler!=null) {
        commandHandler(msg);
      }
    }
  }
  
  void disconnect() {
    this.router.disconnectChannel(this);
  }
  
  void onCommand(String commandName,CommandHandler handler) {
    commandHandlers[commandName] = handler;
  }
  
  void sendMessage(Message msg) {
    msg.sender = this.activity.instanceId;
    activity.iframe.contentWindow.postMessage(msg.data,"*");
  }
}

typedef void CommandHandler(Message msg); 
