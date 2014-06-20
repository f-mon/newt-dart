part of newt;


class ActivityManager {

  Registry registry;
  ActivityDisplay rootDisplay;

  List<Activity> activityStack = new List();
  MessagesRouter messagesRouter;
  IntentExecuter intentExecuter;

  ActivityManager(this.registry, this.rootDisplay) {
    messagesRouter = new MessagesRouter();
    intentExecuter = new IntentExecuter(this);
  }
  
  Future<Activity> startChildActivity(String appName, String activityName) {
    return _startChildActivity(appName, activityName, false);
  }
  
  Future<Activity> startChildPopupActivity(String appName, String activityName) {
    return _startChildActivity(appName, activityName, true);
  }
  
  Future<Activity> _startChildActivity(String appName, String activityName,bool popup) {
    return _pauseCurrentActivity().then((a) {
      return _createAndStartActivity(appName, activityName, a, popup);
    });
  }

  Future<Activity> startRootActivity(String appName, String activityName) {
    return closeAllActivities().then((act){      
      return _createAndStartActivity(appName, activityName, null, false);
    });
  }

  Future<Activity> closeAllActivities() {
    if (activityStack.isEmpty) {
      return new Future(() => null);
    }
    return closeActivity().then((d) {
      return closeAllActivities();
    });
  }

  Future<Activity> closeActivity() {
    if (activityStack.isEmpty) {
      return new Future(() => null);
    } else {
      var currentAct = activityStack.last;
      return currentAct.onClose().then((a) {
        activityStack.remove(a);
        a.activityDisplay.remove(a);
        if (a.isDisplayOwner) {
          a.activityDisplay.destroyDisplayAndResumeParent();
        }
        return _resumeActivity();
      });
    }
  }

  Future<Activity> _resumeActivity() {
    if (activityStack.isEmpty) {
      return new Future(() => null);
    } else {
      var currentAct = activityStack.last;
      return currentAct.onResume().then((a) {
        a.activityDisplay.resumed(a);
        return a;
      });
    }
  }

  Future<Activity> _pauseCurrentActivity() {
    if (activityStack.isEmpty) {
      return new Future(() => null);
    } else {
      var currentAct = activityStack.last;
      return currentAct.onPause().then((a) {
        a.activityDisplay.paused(a);
        return a;
      });
    }
  }

  Future<Activity> _createAndStartActivity(String appName, String activityName, Activity parentActivity, bool popup) {
    
    Application application = registry.getApplication(appName);
    Map activityDef = application.getActivityDef(activityName);
    Activity newActivity = new Activity(application, activityDef, parentActivity, this);
    ActivityDisplay parentDisplay = (parentActivity!=null)?parentActivity.activityDisplay:this.rootDisplay;
    
    if (popup) {      
      newActivity.activityDisplay = parentDisplay.createPopupDisplay();
      newActivity.isDisplayOwner = true;
    } else {      
      newActivity.activityDisplay = parentDisplay;
    }
    
    this.activityStack.add(newActivity);
    
    return newActivity.onStart().then((Activity a) {
      a.activityDisplay.showActive(a);
      return a;
    }).then((Activity a) {
      return a.waitLoaded();
    });
  }

}
