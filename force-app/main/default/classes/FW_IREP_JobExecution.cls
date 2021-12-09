/**
    * @description   Interface for the Job Execution Repository
    * @testClass     N/A
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public interface FW_IREP_JobExecution extends FW_ISObjectRep {

    List<Job_Execution__c> getJobExecwithBatchDefinitionsByIdSet(Set<Id> jobExecutionIdSet);
    List<Job_Execution__c> getJobExecutionByAsyncApexJobIdSet(Id AsyncApexJobId);
    List<Job_Execution__c> getJobExecutionByAsyncApexJobIdSet(Set<Id> asyncApexJobIdSet);
}