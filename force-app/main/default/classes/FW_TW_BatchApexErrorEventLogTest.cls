@isTest
private class FW_TW_BatchApexErrorEventLogTest {
	static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void BatchApexErrorEvent_LogTest(){
        FW_IREP_AsyncApexJob asynApexJobRepository = (FW_REP_AsyncApexJob)mocks.mock(FW_REP_AsyncApexJob.class);
        FW_IREP_JobExecution jobExecutionRepository= (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_ISL_ErrorHandling errorHandler= (FW_SL_ErrorHandling)mocks.mock(FW_SL_ErrorHandling.class);

        SObject job = new AsyncApexJob(
            Id = fflib_IDGenerator.generate(AsyncApexJob.sObjectType)
        );
        
        SObject job2 = new AsyncApexJob();
        job2.put('Id', fflib_IDGenerator.generate(AsyncApexJob.sObjectType));
        
        List<BatchApexErrorEvent> errorList = new List<BatchApexErrorEvent>();
        errorList.add(
            new BatchApexErrorEvent(
                AsyncApexJobId = job2.Id
            )
        );
        
        List<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>();
        jobExecutionList.add(
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                AsyncApexJobId__c = job.Id
            )
        );

        mocks.startStubbing();
            mocks.when(asynApexJobRepository.getAsyncApexJobListByIdSet(new Set<Id>{job2.Id})).thenReturn(new List<AsyncApexJob>{(AsyncApexJob)job2});
            mocks.when(jobExecutionRepository.getJobExecutionByAsyncApexJobIdSet(new Set<Id>{null})).thenReturn(jobExecutionList);
        mocks.stopStubbing();
        
        FW_TW_BatchApexErrorEventLog jobExecutionWorker = new FW_TW_BatchApexErrorEventLog(); 
        jobExecutionWorker = new FW_TW_BatchApexErrorEventLog(asynApexJobRepository, jobExecutionRepository, errorHandler);
        
        jobExecutionWorker.execute(errorList);
        
        ((FW_ISL_ErrorHandling)mocks.verify(errorHandler, 1)).saveLogs();
    }
}