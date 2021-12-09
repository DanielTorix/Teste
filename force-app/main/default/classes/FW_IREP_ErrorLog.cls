/**
    * @description   Error Log repository with all SOQL, SOSL and DML operations
    * @testClass     N/A
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public interface FW_IREP_ErrorLog extends FW_ISObjectRep{
    List<Error_Log__c> getErrorLogListByJobExecutionIdSet(Set<Id> jobExecutionIdSet);
    List<Error_Log__c> getErrorLogListByIdSet(Set<Id> errorLogIdSet);
}