/**
    * @description   Interface for the Job Execution Domain Object Class
**/
public interface FW_IDO_JobExecution {

    Boolean isRunningwithDefaults(Job_Execution__c jobExecution);
    Boolean isJobSizeEqualsToBatchDefinitionJobSize(Job_Execution__c jobExecution, Batch_Definition__c batchDefinition);
    Id executeBatch(Job_Execution__c jobExecution, Batch_Definition__c batchDefinition);
    Integer getDifferenceInMinutesFromNow(DateTime dt1);
    Parameters__c getClonedParameter(Parameters__c parameter, Id jobExecutionId);
    Boolean isToExecute(Job_Execution__c jobExecution);
    Boolean isScheduledRun(Job_Execution__c jobExecution);
    Id scheduleBatch(Job_Execution__c jobExecution, Batch_Definition__c batchDefinition);
    Job_Execution__c createJobExecutionsFromBD(Id batchDefinitionID);
    void abortJob(String asyncId);
}