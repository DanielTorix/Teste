@isTest
private class FW_Async_CleanErrorLogBatchTest {

	@isTest
    private static void testCleanErrorLogSpecificDate(){
        List<CleanErrorLogBatchSettings__c> celbsLst = FW_TestDataFactory.createCleanErrorLogBatchSettings(1, true);
        List<Error_Log__c> errorLst = FW_TestDataFactory.createErrorLog(1,true);
        if(errorLst[0] != null){
            Test.setCreatedDate(errorLst[0].Id, DateTime.newInstance(2010,04,12,0,0,0));
        }
        
        Test.startTest();
        FW_Async_CleanErrorLogBatch batchTest = new FW_Async_CleanErrorLogBatch();
        database.executeBatch(batchTest);
        Test.stopTest();

        List<Error_Log__c> errorsToDelete = new List<Error_Log__c>();
        if(celbsLst[0] != null){
            CleanErrorLogBatchSettings__c celbs = celbsLst[0];
            if(celbs.NumberOfDays__c != null){
                errorsToDelete = Database.query('select id from Error_Log__c where createdDate < '+ DateTime.Now().addDays(-(Integer)celbs.NumberOfDays__c).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\''));
            }
        }
        
        System.assertEquals(true, errorsToDelete.isEmpty(), 'Not Deleted');
    }

    @isTest
    private static void testCleanErrorLogNoDefaultSetting(){
        CleanErrorLogBatchSettings__c celbsLst = new CleanErrorLogBatchSettings__c(Name = 'Test');
        insert celbsLst;
        List<Error_Log__c> errorLst = FW_TestDataFactory.createErrorLog(1,true);

        Test.startTest();
        FW_Async_CleanErrorLogBatch batchTest = new FW_Async_CleanErrorLogBatch();
        database.executeBatch(batchTest);
        Test.stopTest();
        
        List<Error_Log__c> errorsToDelete = [SELECT Id, CreatedDate FROM Error_Log__c];
        System.assertEquals(true, !errorsToDelete.isEmpty(), 'Deleted');
    }

    @isTest
    private static void scheduleBatch(){
        CleanErrorLogBatchSettings__c celbsLst = new CleanErrorLogBatchSettings__c(Name = 'Test');
        insert celbsLst;
        List<Error_Log__c> errorLst = FW_TestDataFactory.createErrorLog(1,true);

        Test.startTest();
        FW_Async_CleanErrorLogBatch batchTest = new FW_Async_CleanErrorLogBatch();
        database.executeBatch(batchTest);
        Test.stopTest();
        
        List<Error_Log__c> errorsToDelete = [SELECT Id, CreatedDate FROM Error_Log__c];
        System.assertEquals(true, !errorsToDelete.isEmpty(), 'Deleted');
    }

    @isTest
    private static void scheduleExecute(){
        
        Test.startTest();
            String scheduleBatchTime = '0 0 23 * * ?';        
            Id schedulerId = system.schedule('Batch Scheduler', scheduleBatchTime, new FW_Async_CleanErrorLogBatch ());
        Test.stopTest();
        
        System.assertEquals(schedulerId.getSObjectType(), CronTrigger.SObjectType);
    }
}