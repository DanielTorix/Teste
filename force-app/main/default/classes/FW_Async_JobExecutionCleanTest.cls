@isTest
private class FW_Async_JobExecutionCleanTest {

    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    private static void FW_Async_JobExecutionCleanExecuteTest(){
        // Create mocked repository object on the fly. 
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);
        FW_IAsync asynHandler = (FW_AsyncHandler)mocks.mock(FW_AsyncHandler.class);

        // Initialize framework        
        //Create Batch_Definition
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Batch_Name__c = 'FW_Async_JobExecutionClean', 
                Class_Name__c = 'batch_test',
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
        
        parametersList.add(
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = FW_AsyncHandler.DEFAULT_PARAMETER
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

        List<Job_Execution__c> jobExecutionList2 = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Run_With_Defaults__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_SCHEDULED
            )
        };
        

        mocks.startStubbing();
            mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
            mocks.when(jobExecutionRep.getJobExecutionByAsyncApexJobIdSet((Id)fflib_match.anyObject())).thenReturn(jobExecutionList);
            mocks.when(parameterRep.getParametersByParentId((Set<Id>)fflib_match.anyObject())).thenReturn(parametersList);
        mocks.stopStubbing();

        FW_Async_JobExecutionClean newBatchRun = new FW_Async_JobExecutionClean();
        newBatchRun = new FW_Async_JobExecutionClean(jobExecutionRep, parameterRep);
		
        Database.executeBatch(newBatchRun);
        newBatchRun.setAsyncApexJobId(null);
        newBatchRun.execute(null, jobExecutionList2);
        
        ((FW_IREP_JobExecution)mocks.verify(jobExecutionRep, 1)).getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject());
        ((FW_IREP_Parameters)mocks.verify(parameterRep, 1)).getParametersByParentId((Set<Id>)fflib_match.anyObject());
    }
}