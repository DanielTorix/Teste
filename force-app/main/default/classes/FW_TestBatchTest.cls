@isTest
private class FW_TestBatchTest {
    
    @isTest
    private static void scheduleExecute(){
        Id schedulerId;
        
        Test.startTest();
            FW_TestBatch testBatch = new FW_TestBatch ();   
            String testBatchSchedTime = '0 0 23 * * ?';        
            schedulerId = system.schedule('Test Batch Scheduler', testBatchSchedTime, testBatch);
        Test.stopTest();
        
        System.assertEquals(schedulerId.getSObjectType(), CronTrigger.SObjectType);
    }
    
    @isTest
    private static void batchExecute(){
        Id batchId;
        FW_TestDataFactory.createBatchDefinition(2,true);
        
        Test.startTest();
            FW_TestBatch testBatch = new FW_TestBatch ();   
            batchId = Database.executeBatch(testBatch, 200);
        Test.stopTest();
        
        System.assertEquals(batchId.getSObjectType(), AsyncApexJob.SObjectType);
    }
}