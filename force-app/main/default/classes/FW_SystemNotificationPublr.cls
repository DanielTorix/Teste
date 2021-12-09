/**
    * @description   global class to publish System Notification platform event
    * @testClass     FW_SystemNotificationPublrTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
global class FW_SystemNotificationPublr {
        
	private static final String ALL_EXCEPTIONS_SETTING_NAME = 'All';
    private string exceptionTypeName;
    private Boolean isDisabled = false;
    private final String errorStringTemplate = 'Error returned: {0} - {1}';
    @testvisible
    private static Boolean isPublisherTest = false;
    @testvisible
    private List<System_Notification__e> notifyList;
    
    public FW_SystemNotificationPublr() {}

    /*
        * @description:         parametrized constructor to publish the error log 
    */
    public FW_SystemNotificationPublr(FW_ErrorAndMonitoringLog error) {
        //to restrict a null error
        System.assert(error != null);
        
        this.notifyList = new List<System_Notification__e>();
        
        if(error.getExceptionWrapper() != null) {
            this.exceptionTypeName = FW_ExceptionWrapper.formatExceptionTypeName(error.getExceptionWrapper().typeName);
            isDisabled();
        }
        
       	// add error logging enable/disable switch here
        if(!this.isDisabled) {
            System_Notification__e notify = prepare(error);
            this.notifyList.add(notify);

        	if(this.notifyList.size() > 0) {
                this.publish();
            }
        }
    }

    /*
        * @description:         parametrized constructor to publish the list of error logs 
    */
    public FW_SystemNotificationPublr(List<FW_ErrorAndMonitoringLog> errorLogList) {
        //to restrict a null error
        System.assert(errorLogList != null);
        this.notifyList = new List<System_Notification__e>();
        
        for(Integer i = 0; i< errorLogList.size(); i++) {
            if(errorLogList[i].getExceptionWrapper() != null) {
                this.exceptionTypeName = FW_ExceptionWrapper.formatExceptionTypeName(errorLogList[i].getExceptionWrapper().typeName);
                if(this.exceptionTypeName != null) {
                    isDisabled();
                }
            }
            if(!this.isDisabled) {
                System_Notification__e notify = prepare(errorLogList[i]);
                this.notifyList.add(notify);
            }
        }
        
       	// add error logging enable/disable switch here
        if(this.notifyList.size() > 0) {
            this.publish();
        }
    }

    /**
        * @description:         Contructs notification content
    */
    private System_Notification__e prepare(FW_ErrorAndMonitoringLog error) {
        System_Notification__e notify = new System_Notification__e();

        notify.Actor_Id__c = error.getActorId();
        notify.Category__c = error.getCategory();
        notify.Origin__c = error.getOrigin();
        notify.Request_Body__c = error.getRequestBody();
        notify.Response_Body__c = error.getResponseBody();
        notify.Error_Message__c = error.getErrorMessage();
        notify.Record_Id__c = error.getRecordId();
        if(error.getExceptionWrapper() !=null) {
            notify.Error_Message__c = error.getExceptionWrapper().message;
       		notify.Exception_Cause__c = string.valueOf(error.getExceptionWrapper().cause);
            notify.StackTraceString__c = error.getExceptionWrapper().stacktraceString;
            notify.Exception_Line_Number__c = error.getExceptionWrapper().lineNumber;
            notify.Exception_Type_Name__c = error.getExceptionWrapper().typeName;
        }

        return notify;
    }

    /**
        * @description:     Publishes notifications for errors      
    */
    private void publish() {
    
        List<Database.SaveResult> srList = EventBus.publish(this.notifyList);
        for (Database.SaveResult sr: srList) {
            for(Database.Error err : sr.getErrors()) {
                System.debug(String.format(errorStringTemplate, new String[] {String.valueOf(err.getStatusCode()), String.valueOf(err.getMessage())}));
            }
        }
    }

    /**
        * @description:     Checks if error loggin is disabled    
    */
    
    private void isDisabled() {
        
        switch on this.exceptionTypeName {
            when 'DmlException' {
                if ((isErrorLoggingDisabled(this.exceptionTypeName) || isErrorLoggingDisabled(ALL_EXCEPTIONS_SETTING_NAME))) {
                    this.isDisabled = true;
                }
            }
            when 'CalloutException', 'QueryException' {
                if ((isErrorLoggingDisabled(this.exceptionTypeName) || isErrorLoggingDisabled(ALL_EXCEPTIONS_SETTING_NAME))) {
                    this.isDisabled = true;
                }
            }
            when else {
                if (isErrorLoggingDisabled(ALL_EXCEPTIONS_SETTING_NAME))
                	this.isDisabled = true;
            }
        }
    }

    /**
        * @description:         to check if error logging is enabled
    */
    private Boolean isErrorLoggingDisabled(string typeOfException) {
        
        System.assert(typeOfException != null);

        FW_DisableErrorLogging__c disableErrorLoggingSetting = FW_DisableErrorLogging__c.getInstance();
        if((Test.isRunningTest() && !isPublisherTest) || disableErrorLoggingSetting == null){
            return false;
        }
        return (Boolean)disableErrorLoggingSetting.get(typeOfException +'__c');
    }
}