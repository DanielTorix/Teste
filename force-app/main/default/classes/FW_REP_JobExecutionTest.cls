@isTest
public class FW_REP_JobExecutionTest {
    @isTest
    static void jobExecutionRepositoryTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        system.runAs(runningUser){  
            Id batchDefinitionId = FW_TestDataFactory.createBatchDefinition(1, true).get(0).Id;
            List<Job_Execution__c> jobExecutionList = FW_TestDataFactory.createJobExecution(2, false, FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_INITIAL, batchDefinitionId);
            jobExecutionList.get(1).AsyncApexJobId__c = fflib_IDGenerator.generate(AsyncApexJob.sObjectType);

            test.startTest();
                FW_REP_JobExecution jobExecutionRepository = new FW_REP_JobExecution();
                jobExecutionRepository.insertSObjects(jobExecutionList);
                List<Job_Execution__c> jobExecutionFromIdSet = jobExecutionRepository.getJobExecwithBatchDefinitionsByIdSet(new Set<Id>{jobExecutionList.get(0).Id, jobExecutionList.get(1).Id});
                List<Job_Execution__c> jobExecutionFromAsyncJobId = jobExecutionRepository.getJobExecutionByAsyncApexJobIdSet(jobExecutionList.get(1).AsyncApexJobId__c);
                List<Job_Execution__c> jobExecutionFromAsyncJobIdSet = jobExecutionRepository.getJobExecutionByAsyncApexJobIdSet(new Set<Id>{null});
                
            test.stopTest();

            system.assertEquals(2, jobExecutionFromIdSet.size());
            system.assertEquals(1, jobExecutionFromAsyncJobId.size());
            system.assertEquals(1, jobExecutionFromAsyncJobIdSet.size());
        }
    }

    @isTest
    static void insertSObjectsTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        system.runAs(runningUser){  
            Id batchDefinitionId = FW_TestDataFactory.createBatchDefinition(1, true).get(0).Id;
            List<Job_Execution__c> jobExecutionList = FW_TestDataFactory.createJobExecution(2, false, FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_INITIAL, batchDefinitionId);

            test.startTest();
                FW_REP_JobExecution jobExecutionRepository = new FW_REP_JobExecution();
                List<Database.SaveResult> saveResultsSuccessList = jobExecutionRepository.insertSObjects(jobExecutionList);

                for( Database.SaveResult res : saveResultsSuccessList ){
                    System.assertEquals(true, res.isSuccess());
                }

                jobExecutionList = FW_TestDataFactory.createJobExecution(2, false, FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_INITIAL, batchDefinitionId);
                jobExecutionList.get(1).Batch_Definition__c = null;
                saveResultsSuccessList = jobExecutionRepository.insertSObjects(jobExecutionList);

                for( Database.SaveResult res : saveResultsSuccessList ){
                    System.assertEquals(false, res.isSuccess());
                }
                
            test.stopTest();  

            // Integration testing to assess events were published:
            Test.getEventBus().deliver();     

            FW_IREP_ErrorLog errorRep = new FW_REP_ErrorLog();
            List<Error_Log__c> errorLogList = errorRep.getErrorLogListByJobExecutionIdSet( new Set<Id>{ jobExecutionList.get(0).Id, jobExecutionList.get(1).Id });
            System.assertEquals(jobExecutionList.size(), errorLogList.size());
        }
    }
}