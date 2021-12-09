/**  
	* @description  Worker class to manage Job executions
	* @testClass    FW_THWA_JobExecution_ManageBatchTest
	* Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------  
**/
public without sharing class FW_TW_JobExecution_ManageBatchBefore {

    private FW_IREP_BatchDefinition batchDefinitionRepository;
    private FW_IDO_JobExecution jobExecutionDO;
    private FW_IREP_JobExecution jobExecutionRepository;

    public FW_TW_JobExecution_ManageBatchBefore() {
        this.batchDefinitionRepository = new FW_REP_BatchDefinition();
        this.jobExecutionDO = new FW_DO_JobExecution();
        this.jobExecutionRepository = new FW_REP_JobExecution();
    }
    
    @TestVisible
    private FW_TW_JobExecution_ManageBatchBefore(FW_IDO_JobExecution jobExecutionDO, FW_IREP_BatchDefinition batchDefinitionRepository, FW_IREP_JobExecution jobExecutionRepository) {
        this.batchDefinitionRepository = batchDefinitionRepository;
        this.jobExecutionDO = jobExecutionDO;
        this.jobExecutionRepository = jobExecutionRepository;
    }
    
    public void execute(List<Job_Execution__c> jobExecList) {
        
        Set<Id> batchDefinitionIdSet = getBatchDefinitionIdSet(jobExecList);
        Map<Id, Batch_Definition__c> batchDefinitionMap = new Map<Id, Batch_Definition__c>(batchDefinitionRepository.getBatchDefinitionByIdSet(batchDefinitionIdSet));

        for(Job_Execution__c jobExecution: jobExecList) {

            if(!jobExecutionDO.isScheduledRun(jobExecution)
                && jobExecutionDO.isToExecute(jobExecution)
                && jobExecution.Status__c == FW_DO_JobExecution.JOB_EXEC_STATUS_NEW){
                executeLocalJob(jobExecution, batchDefinitionMap);
            }else if(jobExecution.Status__c == FW_DO_JobExecution.JOB_EXEC_STATUS_CANCELLED){
                cancelExecution(jobExecution);
            }
        }
    }

    /**
        *  @description:    Execute a Job launched from Salesforce
    **/ 
    private void executeLocalJob(Job_Execution__c jobExecution, Map<Id, Batch_Definition__c> batchDefinitionMap) {
        jobExecution.Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_SCHEDULED;
        jobExecution.RecordTypeId = Schema.SObjectType.Job_Execution__c.getRecordTypeInfosByDeveloperName().get(FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_DEFINED).getRecordTypeId();
        
        if (jobExecution.Scheduled_Execution_DateTime__c <= Datetime.now()) {
            jobExecution.AsyncApexJobId__c = jobExecutionDO.executeBatch(jobExecution, batchDefinitionMap.get(jobExecution.Batch_Definition__c));
        } else {
            jobExecution.AsyncApexJobId__c = jobExecutionDO.scheduleBatch(jobExecution, batchDefinitionMap.get(jobExecution.Batch_Definition__c));
        } 
    }
    
    /**
        *  @description:    Cancel a job execution
    **/
    private void cancelExecution(Job_Execution__c jobExecution){
        
        if (jobExecution.AsyncApexJobId__c != null && jobExecution.AsyncApexJobId__c != '') {
            jobExecutionDO.abortJob(jobExecution.AsyncApexJobId__c);
        } else {
            jobExecution.addError(Label.Batch_Framework_Cancel_Job_Execution_Error);
        }
    }

    /**
        *  @description:    Returns a set of Batch Definition Id for a given list of Job Executions
    **/ 
    private Set<Id> getBatchDefinitionIdSet(List<Job_Execution__c> jobExecutions) {
        Set<Id> batchDefinitionIdSet = new Set<Id>();

        for(Job_Execution__c jobExecution: jobExecutions) {
            batchDefinitionIdSet.add(jobExecution.Batch_Definition__c);
        }
        return batchDefinitionIdSet;
    }

}