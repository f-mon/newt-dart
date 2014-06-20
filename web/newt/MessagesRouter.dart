part of newt;


class MessagesRouter {
  
  Map<String,ActivityChannel> openChannels;
  
  MessagesRouter() {
    openChannels = {};
    window.addEventListener("message",(MessageEvent e) {
      Message msg = new Message(e.data as Map);
      ActivityChannel channel = openChannels[msg.sender];
      if (channel!=null) {
        channel.notifyMessage(msg);
      }
    });
  }
  
  void connectChannel(ActivityChannel activityChannel) {
    var id = activityChannel.activity.instanceId;
    if (openChannels.containsKey(id)) {
      throw new Exception("An ActivityChannel with the same id is already connected!");
    } else {
      openChannels[id] = activityChannel;
    }
  }
  
  void disconnectChannel(ActivityChannel activityChannel) {
    var id = activityChannel.activity.instanceId;
    openChannels.remove(id);
  }
  
}
