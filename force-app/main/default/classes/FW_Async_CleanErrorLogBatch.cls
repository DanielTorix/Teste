/**
    * @description   Not being used in the framework
    * @testClass     FW_Async_CleanErrorLogBatchTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
global class FW_Async_CleanErrorLogBatch implements Database.Batchable<sObject>, Schedulable{

    private FW_IREP_ErrorLog errorLogRep;

    global FW_Async_CleanErrorLogBatch(){
        this.errorLogRep = new FW_REP_ErrorLog();
    }

    global void execute(SchedulableContext sc) {
    }

	global Database.QueryLocator start(Database.BatchableContext bc){
        CleanErrorLogBatchSettings__c celbs = CleanErrorLogBatchSettings__c.getValues('Default');
        String query = '';
        
        if(celbs != null && celbs.ID != null && celbs.NumberOfDays__c != null){
            query = 'select id from Error_Log__c where createdDate < '+ DateTime.Now().addDays(-(Integer)celbs.NumberOfDays__c).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        }
        else{
            query = 'select id from Error_Log__c where createdDate < '+ DateTime.Now().addDays(-30).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        }
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Error_Log__c> errorList){
        if(!errorList.isEmpty()){
            errorLogRep.deleteSObjects(errorList);  
        }
    }

    global void finish (Database.BatchableContext bc){

    }
}