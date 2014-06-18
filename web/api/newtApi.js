
var newt = (function() {
  
  var instanceId=null;
  var waitingsReply = {};
  
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
  
  var onMessage = function(e) {
    if (e.data && 'initialize'==e.data.commandName) {
      instanceId = e.data.instanceId;
	  sendMessageToNewt({
        commandName: 'initialized'
      });
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
          deferred.resolve(result.data.result);
        });
        return deferred;
      }
  };

  var IntentType = {
    START_ACTIVITY : 0,
    START_INTENT : 2
  };

  var Intent = function(type) {
    this.intentType = type;
    this.activity = null;
    this.app = null;
    this.parameters = {};
    this.startMode = "CHILD";

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



