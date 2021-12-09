@isTest
private class FW_TW_JobExecution_CopyBDConfigTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void jobExecutionCopyBDConfigTest(){
        FW_IREP_BatchDefinition batchDefinitionRepository = (FW_REP_BatchDefinition)mocks.mock(FW_REP_BatchDefinition.class);
        
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
                Run_with_Defaults__c = true
                
            )
        );
        
        mocks.startStubbing();
            mocks.when(batchDefinitionRepository.getBatchDefinitionByIdSet(new Set<Id>{batchDefinitionList.get(0).Id})).thenReturn(batchDefinitionList);
        mocks.stopStubbing();
        
        FW_TW_JobExecution_CopyBDConfig jobExecutionWorker = new FW_TW_JobExecution_CopyBDConfig();
        jobExecutionWorker = new FW_TW_JobExecution_CopyBDConfig(batchDefinitionRepository);
        
        jobExecutionWorker.execute(jobExecutionList);
        
        ((FW_IREP_BatchDefinition)mocks.verify(batchDefinitionRepository, 1)).getBatchDefinitionByIdSet((Set<Id>)fflib_match.eq(new Set<Id>{batchDefinitionList.get(0).Id}));
    }
}