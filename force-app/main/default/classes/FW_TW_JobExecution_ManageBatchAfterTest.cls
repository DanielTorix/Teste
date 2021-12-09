@isTest
private class FW_TW_JobExecution_ManageBatchAfterTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void jobExecutionManageBatchAfterTest(){
        FW_IREP_BatchDefinition batchDefinitionRepository = (FW_REP_BatchDefinition)mocks.mock(FW_REP_BatchDefinition.class);
        FW_IDO_JobExecution jobExecutionDomain = (FW_DO_JobExecution)mocks.mock(FW_DO_JobExecution.class);
        FW_IREP_JobExecution jobExecutionRepository = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>();
        batchDefinitionList.add(
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType)
            )  
        );
        
        List<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>();
        jobExecutionList.add(
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Is_Scheduled_run__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
                
            )
        );
        
        mocks.startStubbing();
            mocks.when(jobExecutionDomain.isScheduledRun(jobExecutionList.get(0))).thenReturn(true);
            mocks.when(batchDefinitionRepository.getBatchDefinitionByIdSet(new Set<Id>{batchDefinitionList.get(0).Id})).thenReturn(batchDefinitionList);
        mocks.stopStubbing();
        
        FW_TW_JobExecution_ManageBatchAfter jobExecutionWorker = new FW_TW_JobExecution_ManageBatchAfter();
        jobExecutionWorker = new FW_TW_JobExecution_ManageBatchAfter(jobExecutionDomain, batchDefinitionRepository, jobExecutionRepository);
        
        jobExecutionWorker.execute(jobExecutionList);
        
        ((FW_IREP_JobExecution)mocks.verify(jobExecutionRepository, 1)).updateSObjects((List<Job_Execution__c>)fflib_match.anyList());
    }
}