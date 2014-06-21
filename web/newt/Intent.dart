part of newt;


final String START_ACTIVITY = 'START_ACTIVITY';
final String START_INTENT = 'START_INTENT';

final String CHILD = 'CHILD';
final String ROOT = 'ROOT';
final String CHILD_POPUP = 'CHILD_POPUP';

class Intent {
  
  String intentType;
  Map parameters = {};
  
  // usati solo per il tipo di intent START_ACTIVITY
  String appName;
  String activityName;
  String startMode;
  // -- //
  
  Intent(String this.intentType);
  
  Intent.fromMessage(Message msg) {
      Map intentData = msg.data['intent'];
      intentType = intentData['intentType'];
      parameters = intentData['parameters'];
      appName = intentData['app'];
      activityName = intentData['activity'];
      startMode = intentData['startMode'];
  }
  
}


class IntentExecuter {
  
  ActivityManager activitymanager;
  
  IntentExecuter(this.activitymanager);
  
  Future execute(Intent intent) {
    if (START_ACTIVITY==intent.intentType) {
      return executeStartActivityIntent(intent);
    }
    else if (START_INTENT==intent.intentType) {
      return executeStartIntent(intent);
    } else {
      throw new Exception("Tipo di intent non supportato");
    }
  }
  
  Future<Object> executeStartActivityIntent(Intent intent) {
    if (intent.startMode==CHILD) { 
      return activitymanager.startChildActivity(intent.appName, intent.activityName).then((activity) {
        return activity.waitCompleted();
      });
    } else if (intent.startMode==CHILD_POPUP) {
      return activitymanager.startChildPopupActivity(intent.appName, intent.activityName).then((activity) {
        return activity.waitCompleted();
      });
    } else if (intent.startMode==ROOT) {
      return activitymanager.startRootActivity(intent.appName, intent.activityName).then((activity) {
        return activity.waitCompleted();
      });
    } else {
      throw new Exception("Valore di startMode non supportato");
    }
  }
  
  Future executeStartIntent(Intent intent) {
    //TODO
    return new Completer().future;
  }
  
}



