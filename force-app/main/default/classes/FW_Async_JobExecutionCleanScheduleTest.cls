@isTest
private class FW_Async_JobExecutionCleanScheduleTest {

    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    private static void FW_Async_JobExecutionCleanScheduleExecuteOkTest(){

        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_BatchDefinition batchDefRep = (FW_REP_BatchDefinition)mocks.mock(FW_REP_BatchDefinition.class);
        FW_IDO_JobExecution jobExecutionDO = (FW_DO_JobExecution)mocks.mock(FW_DO_JobExecution.class);

        //Create Batch_Definition
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Batch_Name__c = 'FW_Async_JobExecutionClean', 
                Class_Name__c = 'FW_Async_JobExecutionClean',
                Job_Size__c = 200, 
                SObject_API_Name__c = 'Job_Execution__c'
            )
        };
        
        //Create Parameters 
        List<Parameters__c> parametersList = new List<Parameters__c>{
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = 'Days',
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Value__c = '0'
            )
        };

        parametersList.add(
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = 'Status',
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Value__c = 'Finished,Finished with Errors,Scheduled,Cancelled'
            )
        );

        //Create JobExecution
        List<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Run_With_Defaults__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
            )
        };
        
        mocks.startStubbing();
            mocks.when(batchDefRep.getBatchDefinitionByNameSet((Set<String>)fflib_match.anyObject())).thenReturn(batchDefinitionList);
        mocks.stopStubbing();

        FW_Async_JobExecutionCleanSchedule scheduleJobExec = new FW_Async_JobExecutionCleanSchedule();
        scheduleJobExec = new FW_Async_JobExecutionCleanSchedule(batchDefRep, jobExecutionRep, jobExecutionDO);
        scheduleJobExec.execute(null);

        ((FW_IREP_BatchDefinition)mocks.verify(batchDefRep, 1)).getBatchDefinitionByNameSet((Set<String>)fflib_match.anyObject());
    }

    @isTest
    private static void FW_Async_JobExecutionCleanScheduleExecuteNOkTest(){

        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_BatchDefinition batchDefRep = (FW_REP_BatchDefinition)mocks.mock(FW_REP_BatchDefinition.class);
        FW_IDO_JobExecution jobExecutionDO = (FW_DO_JobExecution)mocks.mock(FW_DO_JobExecution.class);

        //Create Batch_Definition
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>();

        mocks.startStubbing();
            mocks.when(batchDefRep.getBatchDefinitionByNameSet((Set<String>)fflib_match.anyObject())).thenReturn(batchDefinitionList);
        mocks.stopStubbing();

        FW_Async_JobExecutionCleanSchedule scheduleJobExec = new FW_Async_JobExecutionCleanSchedule();
        scheduleJobExec = new FW_Async_JobExecutionCleanSchedule(batchDefRep, jobExecutionRep, jobExecutionDO);
        scheduleJobExec.execute(null);
        
        ((FW_IREP_BatchDefinition)mocks.verify(batchDefRep, 1)).getBatchDefinitionByNameSet((Set<String>)fflib_match.anyObject());

    }
}