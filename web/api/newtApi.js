

window.addEventListener('message',function(e) {
  
  if (e.data && 'initialize'==e.data.eventName) {
    alert("inizializzazione activity comm channel: instanceId="+e.data.instanceId);
    newt.instanceId = e.data.instanceId;
  }

},false);


var newt = {

  instanceId : null,

  sendMessage : function(msg) {
    alert('sendMessage');
    parent.postMessage({
      fromActivity: newt.instanceId,
      conversationId: 'xyz',
      content: msg
    },"*");
  }
  
}


