trigger FW_BatchApexErrorEventTrigger on BatchApexErrorEvent(after insert) {
    if(EventBus.TriggerContext.currentContext().retries < 4){
    	new FW_TH_BatchApexErrorEvent().execute();    
    }
}