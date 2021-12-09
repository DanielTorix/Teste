@isTest
public class FW_REP_ParametersTest {
    @isTest
    static void paremeterRepositoryTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        system.runAs(runningUser){  
            List<Batch_Definition__c> batchDefinitionList = FW_TestDataFactory.createBatchDefinition(1, true);
            List<Job_Execution__c> jobExecutionList = FW_TestDataFactory.createJobExecution(1, true, FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_INITIAL, batchDefinitionList.get(0).Id);
            List<Parameters__c> parameterList = FW_TestDataFactory.createParameter(2, false);
            parameterList.get(0).Job_Execution__c = jobExecutionList.get(0).Id;
            parameterList.get(1).Batch_Definition__c = batchDefinitionList.get(0).Id;
            
            test.startTest();
                FW_REP_Parameters parameterRepository = new FW_REP_Parameters();
                parameterRepository.insertSObjects(parameterList);
                List<Parameters__c> parameterListFromJobExecution = parameterRepository.getParametersByParentId(new Set<Id>{jobExecutionList.get(0).Id});
                List<Parameters__c> parameterListFromBatchDefinition = parameterRepository.getParametersByBatchDefinitionId(new Set<Id>{batchDefinitionList.get(0).Id});
                List<Parameters__c> parameterListFromBatchDefinition2 = parameterRepository.getParametersByBatchDefinitionIdAndName(new Set<Id>{batchDefinitionList.get(0).Id},new Set<String>{'test'});
            test.stopTest();
            
            system.assertEquals(1, parameterListFromJobExecution.size());
            system.assertEquals(2, parameterListFromBatchDefinition.size());
            system.assertEquals(0, parameterListFromBatchDefinition2.size());
        }
    } 
}