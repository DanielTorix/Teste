/**
    * @description   Base class to publish the event and to handle errors if there are any
    * @testClass     N/A
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public virtual class FW_PlatformEventPublisher {
    public List<sObject> notifyList;
    
    public FW_PlatformEventPublisher() {
        this.notifyList = new list<sObject>();
    }

    public FW_PlatformEventPublisher(List<sObject> notifyList) {
        this.notifyList = notifyList;
    }

    public void publish(){
        List<Database.SaveResult> srList = EventBus.publish(this.notifyList);
        
        for (Database.SaveResult sr: srList) {
            if (!sr.isSuccess()) {
                // Get asynchronous operation ID.
                // pass in the operation id and the status code of the first error (only one will exist)
                handleError(String.valueOf(EventBus.getOperationId(sr)), String.valueOf(sr.getErrors()[0].getStatusCode()));
            }
        }
    }

    /**
        *  @description:    Create an error log record        
    */

    private void handleError(String operationId, String errorMessage){
        FW_ErrorAndMonitoringLog errorLog = new FW_ErrorAndMonitoringLog.ErrorDetailsBuilder()
                                .setErrorMessage(errorMessage)
                                .setRecordId(operationId)
                                .setCategory(FW_ErrorAndMonitoringLog.categoryType.Platform_Event)
                                .setActorId(UserInfo.getUserId())
                                .build();
        
        new FW_SystemNotificationPublr(errorLog);
    }
}