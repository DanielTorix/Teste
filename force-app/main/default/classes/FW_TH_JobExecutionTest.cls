@isTest
public class FW_TH_JobExecutionTest {
    @isTest
    static void jobExecutionTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        system.runAs(runningUser){  
            Id batchDefinitionId = FW_TestDataFactory.createBatchDefinition(1, true).get(0).Id;
            List<Job_Execution__c> jobExecutionList = FW_TestDataFactory.createJobExecution(1, false, FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_INITIAL, batchDefinitionId);
            
            User adminUser = FW_TestDataFactory.createUsers(1, false, 'System Administrator', null)[0];
            test.startTest();
                System.runAs(adminUser){
                    insert jobExecutionList;
                    jobExecutionList.get(0).Run_with_Defaults__c = true;
                    update jobExecutionList;
                }
            test.stopTest();
            system.assertNotEquals(null, jobExecutionList.get(0).Id);
        }
    }
}