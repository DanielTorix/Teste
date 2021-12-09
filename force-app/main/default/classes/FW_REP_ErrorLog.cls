/**
    * @description   Error Log repository with all SOQL, SOSL and DML operations
    * @testClass     FW_REP_ErrorLogTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public inherited sharing class FW_REP_ErrorLog extends FW_SObjectRep implements FW_IREP_ErrorLog{
    
    public static final List<SObjectField> ERRORLOG_FIELDS = new SObjectField[] {
        Error_Log__c.Id,
        Error_Log__c.Name,
        Error_Log__c.Actor_Id__c,
        Error_Log__c.Category__c,
        Error_Log__c.Error_Message__c,
        Error_Log__c.Exception_Cause__c,
        Error_Log__c.Exception_Line_Number__c,
        Error_Log__c.Job_Execution__c,
        Error_Log__c.Job_Scope__c,
        Error_Log__c.Origin__c,
        Error_Log__c.Record_Id__c,
        Error_Log__c.Request_Body__c,
        Error_Log__c.Response_Body__c,
        Error_Log__c.StackTraceString__c
    };

    /**
        *  @description:    Method to get a list of Error Log through the job execution Id
    */
    public List<Error_Log__c> getErrorLogListByJobExecutionIdSet(Set<Id> jobExecutionIdSet){
         String query = new FW_QueryBuilder(Error_Log__c.SObjectType)
            .selectFields(ERRORLOG_FIELDS)
            .whereIn(Error_Log__c.Job_Execution__c, new List<Id>(jobExecutionIdSet))
            .getQuery();
       
        return (List<Error_Log__c>)Database.query(query);
    }
    
    /**
        *  @description:    Method to get a list of Error Log through a list of ids
    */
    public List<Error_Log__c> getErrorLogListByIdSet(Set<Id> errorLogIdSet){
         String query = new FW_QueryBuilder(Error_Log__c.SObjectType)
            .selectFields(ERRORLOG_FIELDS)
            .selectParentFields(Error_Log__c.Job_Execution__c, FW_REP_JobExecution.JOBEXECUTION_FIELDS)
            .whereIn(Error_Log__c.Id, new List<Id>(errorLogIdSet))
            .getQuery();
       
        return (List<Error_Log__c>)Database.query(query); 
    }
}