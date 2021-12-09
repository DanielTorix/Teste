/**  
	* @description  Worker class to manage Job executions validations
	* @testClass    FW_TW_JobExecution_ManageBatchAfterTest
	* Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------  
**/
public with sharing class FW_TW_JobExecution_ManageBatchAfter {

    private FW_IREP_BatchDefinition batchDefinitionRepository;
    private FW_IDO_JobExecution jobExecutionDO;
    private FW_IREP_JobExecution jobExecutionRepository;

    public FW_TW_JobExecution_ManageBatchAfter() {
        this.batchDefinitionRepository = new FW_REP_BatchDefinition();
        this.jobExecutionDO = new FW_DO_JobExecution();
        this.jobExecutionRepository = new FW_REP_JobExecution();
    }
    
    @TestVisible
    private FW_TW_JobExecution_ManageBatchAfter(FW_IDO_JobExecution jobExecutionDO, FW_IREP_BatchDefinition batchDefinitionRepository, FW_IREP_JobExecution jobExecutionRepository) {
        this.batchDefinitionRepository = batchDefinitionRepository;
        this.jobExecutionDO = jobExecutionDO;
        this.jobExecutionRepository = jobExecutionRepository;
    }
    
    public void execute(List<Job_Execution__c> jobExecutionList) {
        
        Set<Id> batchDefinitionIdSet = getBatchDefinitionIdSet(jobExecutionList);
        Map<Id, Batch_Definition__c> batchDefinitionMap = new Map<Id, Batch_Definition__c>(batchDefinitionRepository.getBatchDefinitionByIdSet(batchDefinitionIdSet));

        List<Job_Execution__c> jobExecutionsToUpdateList = new List<Job_Execution__c>();
        for(Job_Execution__c jobExecution: jobExecutionList) {

            if(jobExecutionDO.isScheduledRun(jobExecution)){
                jobExecutionsToUpdateList.add(
                    new Job_Execution__c(
                        Id = jobExecution.Id,
                        RecordTypeId = Schema.SObjectType.Job_Execution__c.getRecordTypeInfosByDeveloperName().get(FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_DEFINED).getRecordTypeId(),
                        AsyncApexJobId__c = jobExecutionDO.executeBatch(jobExecution, batchDefinitionMap.get(jobExecution.Batch_Definition__c)),
                        Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_SCHEDULED
                    )
                );
                
            }
        }
        jobExecutionRepository.updateSObjects(jobExecutionsToUpdateList);
    }

    /**
        * @description:         Returns a set of Batch Definition Id for a given list of Job Executions
    */
    private Set<Id> getBatchDefinitionIdSet(List<Job_Execution__c> jobExecutions) {
        Set<Id> batchDefinitionIdSet = new Set<Id>();

        for(Job_Execution__c jobExecution: jobExecutions) {
            batchDefinitionIdSet.add(jobExecution.Batch_Definition__c);
        }
        return batchDefinitionIdSet;
    }
}