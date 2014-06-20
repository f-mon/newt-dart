var newt = (function() {
  
  var instanceId=null;
  var waitingsReply = {};
  
  //funzione base per l'inoltro di un messaggio al container
  var sendMessageToNewt = function(data,replayHandler) {
		var messageId = "message_"+((new Date()).getTime());
		data['fromActivity'] = instanceId;
		data['messageId']=messageId;
		if (replayHandler) {
			waitingsReply[messageId] = {
					callback: replayHandler
			};
		}
		parent.postMessage(data,"*");
  };
  
  var onInitialize = function(e) {
    instanceId = e.data.instanceId;
    sendMessageToNewt({
       commandName: 'initialized'
    });
  };
  
  var onReplyMessage = function(e) {
    var replyTo = e.data.replyTo;
    if (waitingsReply[replyTo]) {
       waitingsReply[replyTo].callback(e);
       delete waitingsReply[replyTo];
    }
  };
  
  var onCommandMessage = function(e) {
    //TODO
  };
  
  //funzione invocata quando arriva un messaggio dal container
  var onMessage = function(e) {
    if (e.data) {
      if ('initialize'==e.data.commandName) {
        onInitialize(e);
      } else if (e.data.replyTo) {
        onReplyMessage(e);
      } else {
        onCommandMessage(e);
      }
    }
  };
  
  window.addEventListener('message',onMessage,false);

  var intentExecutor = {
  
      executeIntent: function(intent,options) {

        //rimuove la funzione altrimenti l'oggetto non è clonabile
        intent.start = null;

        var deferred=null;
        deferred = {
          resolve: function(r) {
            if (deferred._then) {
              deferred._then(r);
            }
          },
          then: function(fn) {
            deferred._then = fn;
          } 
        };
        sendMessageToNewt({
          commandName : 'executeIntent',
          intent: intent,
          options: options
        },function(result) {
          deferred.resolve(result.data);
        });
        return deferred;
      }
  };

  var IntentType = {
    START_ACTIVITY : 'START_ACTIVITY',
    START_INTENT : 'START_INTENT'
  };
  
  var StartMode = {
    CHILD : 'CHILD',
    ROOT : 'ROOT',
    CHILD_POPUP : 'CHILD_POPUP'
  };

  var Intent = function(type) {
    this.intentType = type;
    this.activity = null;
    this.app = null;
    this.parameters = {};
    this.startMode = StartMode.CHILD;

    this.start = function(options) {
      return intentExecutor.executeIntent(this,options);
    };
  };
  

  return {

	  sendMessage : function(msg) {
  		sendMessageToNewt({
  			content: msg
  		});
	  },
	  
	  newActivityIntent : function(appId, activityName, parameters) {
  		var i = new Intent(IntentType.START_ACTIVITY);
  		i.activity = activityName;
  		i.parameters = parameters;
  		i.app = appId;
  		return i;
	  }
  
  };


})();



