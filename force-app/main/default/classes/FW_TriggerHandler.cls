/**
    * @description   framework class to manage trigger execution and exception handling
    * @testClass     FW_TriggerHandlerTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
 */
public virtual class FW_TriggerHandler {

    private static Integer nestedCount = 0;
    private static List<String> stacktraceList = new List<String>();
    private static final String ALL_TRIGGERS_SETTING_NAME = 'All';
    
    @testVisible
    private static Boolean isTriggerHandlerTest = false;
    @testVisible
    private static Boolean forceException = false;
    @testVisible
    private static Map<String,Boolean> runOnceMap = new Map<String,Boolean>();
    
    public List<SObject> objectList { get { return Trigger.new != null ? Trigger.new: Trigger.newMap != null? Trigger.newMap.values(): Trigger.oldMap.values();} }
    public Set<Id> objectIdSet { get { return Trigger.newMap != null ? Trigger.newMap.keySet() : Trigger.oldMap !=null? Trigger.oldMap.keySet() : null; } }

    /**
        * @description:         method to set trigger run event to control recursion
    */
    public void setHasRun(String name){
        runOnceMap.put(name, true);
    }
    
    /**
        * @description:         method to get trigger run event to control recursion
    */
    public boolean getHasRun(String name) {
        if(runOnceMap.containsKey(name)) {
            return runOnceMap.get(name);
        }
        return false;
    }

    /**
        * @description:         The name of the trigger listener class
    */
    public String name {
        get { return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')); }
    }

    /**
        * @description:         Executes the logic in this trigger event listener.
    */
    public void execute() {
        if (this.shouldExecute()) {
                doExecute();
        }
    }

    /**
        * @description:         Executes the logic in this trigger event listener.
    */
    private void doExecute() {
        Integer currentNestedCount = ++nestedCount;
        
        try {
            if(forceException) {
                throw new FW_TriggerException('Forced exception');
            }
            switch on Trigger.operationType {
                when AFTER_UPDATE {
                    this.executeAfterUpdate();
                }
                when AFTER_INSERT {
                    this.executeAfterInsert();
                }
                when AFTER_DELETE {
                    this.executeAfterDelete();
                }
                when AFTER_UNDELETE {
                    this.executeAfterUndelete();
                }
                when BEFORE_UPDATE {
                    this.executeBeforeUpdate();
                }
                when BEFORE_DELETE {
                    this.executeBeforeDelete();
                }
                when BEFORE_INSERT {
                    this.executeBeforeInsert();
                }
            }			
        }catch (Exception ex) {
            if (!this.isBatch()) {
                stacktraceList.add(ex.getStackTraceString());
                //step 1: Handle exception
                if(currentNestedCount == 1){
                    this.handleException(ex);
                }
                
            }
            
            //Step 2: addError to UI
            for(Sobject sobj: this.objectList) {
                sobj.addError(Label.Error_Message+'\n'+ ex.getMessage());
        	}
        }
    }
     
    /**
        * @description:         handleException This method is used to wrap an exception and publish it via platform event
    */
    @TestVisible
    private void handleException(Exception ex) {
        
        //step 1: wrap the exception
        FW_ExceptionWrapper exceptionWrapper = FW_ExceptionWrapper.exceptionWrapperFactory(ex);
        
        //step 2: build the error and monitoring log
        FW_ErrorAndMonitoringLog errorLog = new FW_ErrorAndMonitoringLog.ErrorDetailsBuilder()
                                .setExceptionWrapper(exceptionWrapper)
                                .setRecordId(string.valueOf(this.objectIdSet != NULL ? this.objectIdSet : NULL))
                                .setCategory(FW_ErrorAndMonitoringLog.categoryType.Apex_Trigger)
                                .setActorId(UserInfo.getUserId())
                                .build();
        
        //Step 3: handle exception via publishing platform event
        new FW_SystemNotificationPublr(errorLog);
    }

    /**
        * @description:         to check if trigger log error while a batch runs
    */
    private Boolean isBatch() {
        return System.isBatch();
    }

    /**
        * @description:         to check if a trigger handler should execute
    */
    private Boolean shouldExecute() {
        if (Test.isRunningTest() && !isTriggerHandlerTest) {
            return true;
        }
        return (!this.allEnabled() && !this.sObjectEnabled());
    }

    /**
        * @description:         to check if a trigger handler is enabled
    */
    private Boolean isEnabled(String scope) {
        
        FW_TriggerHandlerSettings__c triggerHandlerSettings = FW_TriggerHandlerSettings__c.getInstance();
        Boolean isEnabledAux = false;

        try{
            isEnabledAux =  (Boolean)triggerHandlerSettings.get(scope + '__c');
        } catch (SObjectException e) {
            isEnabledAux = false;
        }
        if(isEnabledAux == null){
            return false;
        }
        return isEnabledAux;
    }

    /**
        * @description:         to check if all trigger handlers are enabled via custom setting
    */
    private Boolean allEnabled() {
        return this.isEnabled(ALL_TRIGGERS_SETTING_NAME);
    }

    /**
        * @description:         For disabling a custom object in the Trigger Handler Settings create a field replacing 
                                the double underscores __ with a single one, since __ is not allowed in field names.
                                For instance to disable a trigger on [managed package prefix]__[custom object]__c create a 
                                field called [managed package prefix]_[custom object]_c
    */
    private Boolean sObjectEnabled() {
        String objectType = String.valueOf(this.objectList.getSObjectType()).replace('__', '_');
        return this.isEnabled(objectType);
    }

    /**
        * @description:         Handles the afterUpdate events
    */
    protected virtual void executeAfterUpdate() {}

    /**
        * @description:         Handles the afterInsert events
    */
    protected virtual void executeAfterInsert() {} 

    /**
        * @description:         Handles the afterDelete events
    */
    protected virtual void executeAfterDelete() {} 

    /**
        * @description:         Handles the afterUndelete events
    */
    protected virtual void executeAfterUndelete() {} 

    /**
        * @description:         Handles the beforeUpdate events
    */
    protected virtual void executeBeforeUpdate() {} 

    /**
        * @description:         Handles the beforeInsert events
    */
    protected virtual void executeBeforeInsert() {} 

    /**
        * @description:         Handles the beforeDelete events
    */
    protected virtual void executeBeforeDelete() {}

}