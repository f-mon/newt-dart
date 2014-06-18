part of newt;


class MessagesRouter {
  
  ActivityManager activitymanager;
  
  MessagesRouter(ActivityManager this.activitymanager) {
    window.addEventListener("message",(MessageEvent e) {
      print("ricevuto: ${e.data}");
    });
  }
  
}