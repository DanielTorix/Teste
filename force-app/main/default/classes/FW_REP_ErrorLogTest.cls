@isTest
public class FW_REP_ErrorLogTest {
    @isTest
    static void errorLogRepositoryTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        system.runAs(runningUser){    
            Id batchDefinitionId = FW_TestDataFactory.createBatchDefinition(1, true).get(0).Id;
            List<Job_Execution__c> jobExecutionList = FW_TestDataFactory.createJobExecution(1, true, FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_INITIAL, batchDefinitionId);
            List<Error_Log__c> errorLogList = FW_TestDataFactory.createErrorLog(1, false);
            errorLogList.get(0).Job_Execution__c = jobExecutionList.get(0).Id;
            insert errorLogList;
            
            test.startTest();
                FW_REP_ErrorLog errorLogRepository = new FW_REP_ErrorLog();
                List<Error_Log__c> errorLogFromJobExecution = errorLogRepository.getErrorLogListByJobExecutionIdSet(new Set<Id>{errorLogList.get(0).Job_Execution__c});
                List<Error_Log__c> errorLogFromId = errorLogRepository.getErrorLogListByIdSet(new Set<id>{errorLogList.get(0).Id});
            test.stopTest();
            
            system.assertEquals(1, errorLogFromJobExecution.size());
            system.assertEquals(1, errorLogFromId.size());
        }
    }
}