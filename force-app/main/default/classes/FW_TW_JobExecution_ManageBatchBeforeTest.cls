@isTest
private class FW_TW_JobExecution_ManageBatchBeforeTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    private static void jobExecutionManageBatchBeforeTest(){

        //Mocking
        FW_IREP_BatchDefinition batchDefinitionRepository = (FW_REP_BatchDefinition)mocks.mock(FW_REP_BatchDefinition.class);
        FW_IDO_JobExecution jobExecutionDomain = (FW_DO_JobExecution)mocks.mock(FW_DO_JobExecution.class);
        FW_IREP_JobExecution jobExecutionRepository = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        
        //Data Setup
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
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW,
                Scheduled_Execution_DateTime__c = DateTime.Now().addMinutes(-1)
                
            )
        );
        jobExecutionList.add(
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW,
                Scheduled_Execution_DateTime__c = DateTime.Now().addMinutes(1)
            )
        );
        jobExecutionList.add(
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_CANCELLED,
                Scheduled_Execution_DateTime__c = DateTime.Now().addMinutes(1)
            )
        );
        jobExecutionList.add(
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_CANCELLED,
                Scheduled_Execution_DateTime__c = DateTime.Now().addMinutes(1),
                AsyncApexJobId__c = '1234'
            )
        );
        
        //Stubing
        mocks.startStubbing();
            mocks.when(jobExecutionDomain.isScheduledRun(jobExecutionList.get(0))).thenReturn(false);
            mocks.when(jobExecutionDomain.isScheduledRun(jobExecutionList.get(1))).thenReturn(false);
            mocks.when(jobExecutionDomain.isScheduledRun(jobExecutionList.get(2))).thenReturn(true);
            mocks.when(jobExecutionDomain.isScheduledRun(jobExecutionList.get(3))).thenReturn(true);
            mocks.when(jobExecutionDomain.isToExecute(jobExecutionList.get(0))).thenReturn(true);
            mocks.when(jobExecutionDomain.isToExecute(jobExecutionList.get(1))).thenReturn(true);
            mocks.when(jobExecutionDomain.isToExecute(jobExecutionList.get(2))).thenReturn(false);
            mocks.when(jobExecutionDomain.isToExecute(jobExecutionList.get(3))).thenReturn(false);
            mocks.when(batchDefinitionRepository.getBatchDefinitionByIdSet(new Set<Id>{batchDefinitionList.get(0).Id})).thenReturn(batchDefinitionList);
        mocks.stopStubbing();
        
        //Test execution
        FW_TW_JobExecution_ManageBatchBefore jobExecutionWorker = new FW_TW_JobExecution_ManageBatchBefore();
        jobExecutionWorker = new FW_TW_JobExecution_ManageBatchBefore(jobExecutionDomain, batchDefinitionRepository, jobExecutionRepository);
        
        jobExecutionWorker.execute(jobExecutionList);

        //Test ValidationFW_TW_JobExecution_ManageBatchBeforeTest
        String errorMessage = '';
        if(ApexPages.getMessages().size() > 0){
            errorMessage = ApexPages.getMessages().get(0).getSummary();
        }

        ((FW_IDO_JobExecution)mocks.verify(jobExecutionDomain, 1)).executeBatch(jobExecutionList.get(0),batchDefinitionList.get(0));
        ((FW_IDO_JobExecution)mocks.verify(jobExecutionDomain, 1)).scheduleBatch(jobExecutionList.get(1),batchDefinitionList.get(0));
        ((FW_IDO_JobExecution)mocks.verify(jobExecutionDomain, 1)).abortJob('1234');
        System.assertEquals(Label.Batch_Framework_Cancel_Job_Execution_Error, errorMessage, 'Wrong Error Message Added to Job Execution');
    }
}