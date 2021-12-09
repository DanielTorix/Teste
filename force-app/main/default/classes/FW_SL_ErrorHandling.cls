/**
    * @description   Error Handling Class
    * @testClass     FW_SL_ErrorHandlingTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public class FW_SL_ErrorHandling implements FW_ISL_ErrorHandling {

    @TestVisible
    private List<Error_Log__c> errorListToWrite;
    private FW_IREP_ErrorLog errorRepository;

    //Default Constructor to be used
    public FW_SL_ErrorHandling(){
        errorListToWrite = new List<Error_Log__c>();
        errorRepository = new FW_REP_ErrorLog();
    }

    @TestVisible
    private FW_SL_ErrorHandling(FW_IREP_ErrorLog errorRepository){
        errorListToWrite = new List<Error_Log__c>();
        this.errorRepository = errorRepository;
    }

    /**
        * @description:    Create a log record for a job execution error
    */

    public void writeLog(System_Notification__e event) {
        
        //Create new error record 
        Error_Log__c error = new Error_Log__c();
        error.Actor_Id__c = event.Actor_Id__c;
        error.Record_Id__c = event.Record_Id__c;
        error.Category__c = event.Category__c;
        error.Error_Message__c = event.Error_Message__c;
        error.Exception_Cause__c = event.Exception_Cause__c;
        error.Exception_Line_Number__c = event.Exception_Line_Number__c;
        error.Exception_Type_Name__c = event.Exception_Type_Name__c;
        error.Origin__c = event.Origin__c;
        error.Request_Body__c = event.Request_Body__c;
        error.Response_Body__c = event.Response_Body__c;
        error.StackTraceString__c = event.StackTraceString__c;
        try{
            ID userId = Id.valueOf(event.Actor_Id__c);
            if(userId.getSobjectType() == Schema.User.SObjectType){
                error.Actor_Name__c = userId;
            }
        } catch (Exception e){
            System.debug('Not a Valid ID =' + e);
        }
        errorListToWrite.add(error);
    }

    /**
        * @description:    Create a log record for a job execution error
    */
    public void writeLog(BatchApexErrorEvent event, Id jobId) {
        
        Error_Log__c error = new Error_Log__c();
        error.Job_Execution__c = jobId;
        error.Error_Message__c = event.Message;
        error.StackTraceString__c = event.StackTrace;
        error.Category__c = 'Apex_Batch';
        error.Exception_Type_Name__c = event.ExceptionType;
        error.Job_Scope__c = event.JobScope;
        
        errorListToWrite.add(error);
    }

    /**
        * @description:    Insert a a list of log records
    */
    public void saveLogs() {
        errorRepository.insertSObjects(errorListToWrite);
    }
    
}