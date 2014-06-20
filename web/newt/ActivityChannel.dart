part of newt;


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
    msg.channel = this;
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

class Message {
  
  static int count = 0;
  
  //il Channel nel quale viene notificato questo messaggio
  ActivityChannel channel;
  Map<String,Object> data;

  Message(Map this.data);
  
  Message.create() {
    this.data = new Map();
    this.messageId = "msg_${count++}";
  }
  
  String get messageId => data['messageId'];
  void set messageId(String s) {
    data['messageId'] = s;
  }
  
  String get sender => data['fromActivity'];
  void set sender(String s) {
    data['fromActivity'] = s;
  }
  
  String get commandName => data['commandName'];
  void set commandName(String s) {
    data['commandName'] = s;
  }
  
  String get replyTo => data['replyTo'];
  void set replyTo(String s) {
    data['replyTo'] = s;
  }

  void reply(Message message) {
    message.replyTo = this.messageId;
    this.channel.sendMessage(message);
  }

}