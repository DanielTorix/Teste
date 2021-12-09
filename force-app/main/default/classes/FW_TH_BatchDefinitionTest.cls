@isTest
private class FW_TH_BatchDefinitionTest {
	
    @isTest
    private static void BatchDefinition_AfterTest(){
        List<Batch_Definition__c> batchDefinitionList;
        User adminUser = FW_TestDataFactory.createUsers(1, false, 'System Administrator', null)[0];
        test.startTest();
            System.runAs(adminUser){
                batchDefinitionList = FW_TestDataFactory.createBatchDefinition(1, true);
            }
        test.stopTest();
        system.assertNotEquals(null, batchDefinitionList.get(0).Id);
    }
}