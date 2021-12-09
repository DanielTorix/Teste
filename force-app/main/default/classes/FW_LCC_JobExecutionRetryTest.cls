@isTest
public class FW_LCC_JobExecutionRetryTest {
    
    @isTest
    static void createJobExecutionsRunwithDefault_Test(){
        
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        List<Batch_Definition__c> batchDefinitionList;
        system.runAs(runningUser){
            batchDefinitionList = FW_TestDataFactory.createBatchDefinition(1,true);
        }
        
        List<Job_Execution__c> jobExecutionList = FW_TestDataFactory.createJobExecution(1,true,FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_INITIAL, batchDefinitionList.get(0).id);

        List<Error_Log__c> errorLogList = FW_TestDataFactory.createErrorLog(1,false);
        errorLogList.get(0).Job_Scope__c = 'id1,id2';
        errorLogList.get(0).Job_Execution__c = jobExecutionList.get(0).id;
        insert errorLogList;

        test.startTest();

            system.runAs(runningUser){
                List<Parameters__c> parameterList = FW_TestDataFactory.createParameter(1,false);
                parameterList.get(0).Batch_Definition__c = batchDefinitionList.get(0).id;
                insert parameterList;
        
                map<id,Error_Log__c> errorLogMap = new map<id,Error_Log__c>([select id from Error_Log__c]);
                list<Id> errorLogIdList = new list<id>(errorLogMap.keySet());
    
            
                FW_LCC_JobExecutionRetry.createJobExecutions(errorLogIdList);
            }
        test.stopTest();

        System.assertNotEquals(null, [select id from Parameters__c where Job_Execution__c = :jobExecutionList.get(0).id]);

    }

    @isTest
    static void createJobExecutionsRunwithoutDefault_Test(){

        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        List<Batch_Definition__c> batchDefinitionList;
        system.runAs(runningUser){
            batchDefinitionList = FW_TestDataFactory.createBatchDefinition(1,true);
        }
        
        List<Job_Execution__c> jobExecutionList = FW_TestDataFactory.createJobExecution(1,false,FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_INITIAL, batchDefinitionList.get(0).id);
        jobExecutionList.get(0).Run_with_Defaults__c = false;
        insert jobExecutionList;

        List<Error_Log__c> errorLogList = FW_TestDataFactory.createErrorLog(1,false);
        errorLogList.get(0).Job_Scope__c = 'id1,id2';
        errorLogList.get(0).Job_Execution__c = jobExecutionList.get(0).id;
        insert errorLogList;
        
        test.startTest();
        
            system.runAs(runningUser){
                List<Parameters__c> parameterList = FW_TestDataFactory.createParameter(1,false);
                parameterList.get(0).Batch_Definition__c = batchDefinitionList.get(0).id;
                insert parameterList;
        
                map<id,Error_Log__c> errorLogMap = new map<id,Error_Log__c>([select id from Error_Log__c]);
                list<Id> errorLogIdList = new list<id>(errorLogMap.keySet());
                
                FW_LCC_JobExecutionRetry.createJobExecutions(errorLogIdList);
            }
        test.stopTest();

        System.assertNotEquals(null, [select id from Parameters__c where Job_Execution__c = :jobExecutionList.get(0).id]);
    }

    @isTest
    static void getErrorList_Test(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        List<Batch_Definition__c> batchDefinitionList;
        system.runAs(runningUser){
            batchDefinitionList = FW_TestDataFactory.createBatchDefinition(1,true);
        }
        List<Job_Execution__c> jobExecutionList = FW_TestDataFactory.createJobExecution(1,true,FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_INITIAL, batchDefinitionList.get(0).id);
        List<Error_Log__c> errorLogList = FW_TestDataFactory.createErrorLog(1,false);
        
        errorLogList.get(0).Job_Scope__c = 'id1,id2';
        errorLogList.get(0).Job_Execution__c = jobExecutionList.get(0).id;
        insert errorLogList;
        
        List<Error_Log__c> errorLogReturnList;
        
        test.startTest();
                
            system.runAs(runningUser){
        
                List<Parameters__c> parameterList = FW_TestDataFactory.createParameter(1,false);
                parameterList.get(0).Batch_Definition__c = batchDefinitionList.get(0).id;
                insert parameterList;
        
                map<id,Error_Log__c> errorLogMap = new map<id,Error_Log__c>([select id from Error_Log__c]);
                list<Id> errorLogIdList = new list<id>(errorLogMap.keySet());
    
               errorLogReturnList = FW_LCC_JobExecutionRetry.getErrorList(jobExecutionList.get(0).id);
            }
        test.stopTest();

        System.assertEquals(1, errorLogReturnList.size());   

    }
}