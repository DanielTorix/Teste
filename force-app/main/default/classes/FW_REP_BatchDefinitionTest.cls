@isTest
public class FW_REP_BatchDefinitionTest {
    @isTest
    static void getBatchDefinitionByIdSetTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        system.runAs(runningUser){
            List<Batch_Definition__c> batchDefinitionList = FW_TestDataFactory.createBatchDefinition(1, true);

            test.startTest();
                FW_REP_BatchDefinition batchDefinitionRepository = new FW_REP_BatchDefinition();
                List<Batch_Definition__c> retrievedBatchDefinitionList = batchDefinitionRepository.getBatchDefinitionByIdSet(new Set<Id>{batchDefinitionList.get(0).Id});
            test.stopTest();
            
            system.assertEquals(batchDefinitionList.size(), retrievedBatchDefinitionList.size());
        }
    }

    @isTest
    static void getBatchDefinitionByNameSetTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        system.runAs(runningUser){
            List<Batch_Definition__c> batchDefinitionList = FW_TestDataFactory.createBatchDefinition(1, true);

            test.startTest();
                FW_REP_BatchDefinition batchDefinitionRepository = new FW_REP_BatchDefinition();
                List<Batch_Definition__c> retrievedBatchDefinitionList = batchDefinitionRepository.getBatchDefinitionByNameSet(new Set<String>{batchDefinitionList.get(0).Batch_Name__c});
            test.stopTest();

            system.assertEquals(1, retrievedBatchDefinitionList.size());
            system.assertEquals('Test 0', retrievedBatchDefinitionList[0].Batch_Name__c);
        }
    }
}