@isTest
public class FW_DO_JobExecutionTest {

    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    static FW_DO_JobExecution jobExecutionDomain = new FW_DO_JobExecution();
    private static FW_REP_CronTrigger cronTriggerRep = new FW_REP_CronTrigger();
    
    @isTest
    static void getClonedParameterTest(){
        Job_Execution__c jobExecution = new Job_Execution__c(
            Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType)
        );
        
        Parameters__c parameter = new Parameters__c(
            Id = fflib_IDGenerator.generate(Parameters__c.sObjectType)
        );
        
        Parameters__c clonedParameter = jobExecutionDomain.getClonedParameter(parameter, jobExecution.Id);

        system.assertEquals(clonedParameter.Job_Execution__c, jobExecution.Id);
        system.assertEquals(clonedParameter.Batch_Definition__c, null);
        system.assertEquals(parameter.Id, clonedParameter.getCloneSourceId());
    }
    
    @isTest
    static void isToExecuteTest(){
        Job_Execution__c jobExecution = new Job_Execution__c(
            Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType)
        );
        Boolean isToExecute = jobExecutionDomain.isToExecute(jobExecution);
        system.assertEquals(false, isToExecute);

        jobExecution.Execute__c = true;
        isToExecute = jobExecutionDomain.isToExecute(jobExecution);
        system.assertEquals(true, isToExecute);
    }

    @isTest
    static void isScheduledRunTest(){
        Job_Execution__c jobExecution = new Job_Execution__c(
            Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType)
        );
        Boolean isScheduledRun = jobExecutionDomain.isScheduledRun(jobExecution);
        system.assertEquals(false, isScheduledRun);

        jobExecution.Is_Scheduled_run__c = true;
        isScheduledRun = jobExecutionDomain.isScheduledRun(jobExecution);
        system.assertEquals(true, isScheduledRun);
    }

    @isTest
    static void isJobSizeEqualsToBatchDefinitionJobSizeTest(){
        Job_Execution__c jobExecution = new Job_Execution__c(
            Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
            Job_Size__c = 10,
            Execute__c = true
        );
        
        Batch_Definition__c batchDefinition = new Batch_Definition__c(
            Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
            Job_Size__c = 10
        );
        
        Boolean isJobSizeEqual = jobExecutionDomain.isJobSizeEqualsToBatchDefinitionJobSize(jobExecution, batchDefinition);
        system.assertEquals(true, isJobSizeEqual);

        batchDefinition.Job_Size__c = 5;
        isJobSizeEqual = jobExecutionDomain.isJobSizeEqualsToBatchDefinitionJobSize(jobExecution, batchDefinition);
        system.assertEquals(false, isJobSizeEqual);
    }
    
    @isTest
    static void isRunningwithDefaultsTest(){
        Job_Execution__c jobExecution = new Job_Execution__c(
            Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType)
        );
        
        Boolean isRunningwithDefaults = jobExecutionDomain.isRunningwithDefaults(jobExecution);
        system.assertEquals(false, isRunningwithDefaults);

        jobExecution.Run_with_Defaults__c = true;
        isRunningwithDefaults = jobExecutionDomain.isRunningwithDefaults(jobExecution);
        system.assertEquals(true, isRunningwithDefaults);
    }
    
    @isTest
    static void executeBatchTest(){
        
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IAsync asynHandler = (FW_AsyncHandler)mocks.mock(FW_AsyncHandler.class);
        
        Batch_Definition__c batchDefinition = new Batch_Definition__c(
            Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
            Job_Size__c = 10,
            Class_Name__c = 'FW_TestBatch'
        );

        List<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinition.Id,
                Job_Size__c = batchDefinition.Job_Size__c
            )
        };

        System.assertEquals(true, jobExecutionDomain.isJobSizeEqualsToBatchDefinitionJobSize(jobExecutionList.get(0),batchDefinition));

        mocks.startStubbing();
            mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
        mocks.stopStubbing();

        Id batchApexSyncId = jobExecutionDomain.executeBatch(jobExecutionList.get(0),batchDefinition);

        System.assertEquals( batchApexSyncId.getSObjectType(), AsyncApexJob.sObjectType);

        try{
            jobExecutionList.get(0).Job_Size__c = 0;
            batchApexSyncId = jobExecutionDomain.executeBatch(jobExecutionList.get(0),batchDefinition);
        } catch(Exception e){
            System.assertEquals('batchSize must be greater than or equal to one', e.getMessage());
        }
    }

    @isTest
    static void scheduleBatchTest(){

        Batch_Definition__c batchDefinition = new Batch_Definition__c(
            Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
            Job_Size__c = 10,
            Class_Name__c = 'FW_TestBatch',
            Batch_Name__c = 'batch test'
        );

        Datetime jobExecutionTime = DateTime.Now().addMinutes(1);
        Job_Execution__c jobExecution = new Job_Execution__c(
            Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
            Batch_Definition__c = batchDefinition.Id,
            Job_Size__c = batchDefinition.Job_Size__c,
            Scheduled_Execution_DateTime__c = jobExecutionTime            
        );

        System.assertEquals(true, jobExecutionDomain.isJobSizeEqualsToBatchDefinitionJobSize(jobExecution,batchDefinition));

        Id cronTriggerSchedJobId = jobExecutionDomain.scheduleBatch(jobExecution,batchDefinition);

        System.assertEquals( cronTriggerSchedJobId.getSObjectType(), CronTrigger.sObjectType);
        
        List<CronTrigger> cronTriggerList = cronTriggerRep.getCronTriggerListById(new List<Id>{cronTriggerSchedJobId});
        System.assertEquals(
            'Scheduled Job -' + String.valueOf(jobExecutionTime) + ' - ' + batchDefinition.Batch_Name__c,
            cronTriggerList[0].CronJobDetail.Name
        );
        /*System.assertEquals(
            Datetime.now().addMinutes(jobExecutionDomain.getDifferenceInMinutesFromNow(jobExecution.Scheduled_Execution_DateTime__c)),
            cronTriggerList[0].NextFireTime
        );
        */
        try{
            jobExecution.Job_Size__c = 0;
            cronTriggerSchedJobId = jobExecutionDomain.scheduleBatch(jobExecution,batchDefinition);
        } catch(Exception e){
            System.assertEquals('scopeSize must be greater than or equal to one', e.getMessage());
        }
    }

    @isTest
    static void getDifferenceInMinutesFromNowTest(){

        Integer minuteDiff = jobExecutionDomain.getDifferenceInMinutesFromNow(DateTime.Now().addMinutes(5));
        System.assert( minuteDiff != null );
        /* No additional complexity on asserts added (e.g. assert that the return is 5 or 6, for 5 added minutes)
        due to the unpredictableness of behavior of DateTime logic */
    }

    @isTest
    static void createJobExecutionsFromBDTest(){
        Batch_Definition__c batchDefinition = new Batch_Definition__c(
            Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType)
        );

        Job_Execution__c jobExecution = jobExecutionDomain.createJobExecutionsFromBD(batchDefinition.Id);
        System.assertEquals(batchDefinition.Id, jobExecution.Batch_Definition__c);
        System.assertEquals(true, jobExecution.Is_Scheduled_run__c);
    }

    @isTest
    static void abortJobTest(){

        List<Id> cronJobIdSet = new List<Id>();

        Batch_Definition__c batchDefinition = new Batch_Definition__c(
            Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
            Job_Size__c = 10,
            Class_Name__c = 'FW_TestBatch',
            Batch_Name__c = 'batch test'
        );

        Job_Execution__c jobExecution = new Job_Execution__c(
            Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
            Batch_Definition__c = batchDefinition.Id,
            Job_Size__c = batchDefinition.Job_Size__c,
            Scheduled_Execution_DateTime__c = DateTime.Now().addMinutes(1)            
        );

        System.assertEquals(true, jobExecutionDomain.isJobSizeEqualsToBatchDefinitionJobSize(jobExecution,batchDefinition));

        Id cronTriggerSchedJobId = jobExecutionDomain.scheduleBatch(jobExecution,batchDefinition);
        cronJobIdSet.add(cronTriggerSchedJobId);

        jobExecution.Scheduled_Execution_DateTime__c = DateTime.Now().addMinutes(5);
        cronTriggerSchedJobId = jobExecutionDomain.scheduleBatch(jobExecution,batchDefinition);
        cronJobIdSet.add(cronTriggerSchedJobId);

        jobExecutionDomain.abortJob( cronJobIdSet[0] );

        // Job gets deleted from CronTrigger after being aborted
        System.assertEquals(1, cronTriggerRep.getCronTriggerListById(cronJobIdSet).size());

        try{
            Id asyncJobId = fflib_IDGenerator.generate(AsyncApexJob.sObjectType);
            jobExecutionDomain.abortJob( asyncJobId );
        } catch(Exception e){
            System.assertEquals('Job does not exist or is already aborted.', e.getMessage());
        }
    }
}