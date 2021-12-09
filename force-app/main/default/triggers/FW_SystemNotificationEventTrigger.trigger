/**
 * @Description  PLATFORM EVENT SUBSCRIBER 
 */
trigger FW_SystemNotificationEventTrigger on System_Notification__e (after insert) {
      
    FW_SL_ErrorHandling handler = new FW_SL_ErrorHandling();
      
    for (System_Notification__e event : Trigger.New) {
        handler.writeLog(event);
    }

    handler.saveLogs();
}