@IsTest
private class FW_SL_ErrorHandlingTest {
   
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    private static void TestErrorBatchCreation() {

        FW_IREP_ErrorLog errorRep = (FW_REP_ErrorLog)mocks.mock(FW_REP_ErrorLog.class);

        List<BatchApexErrorEvent> systemNotification = new List<BatchApexErrorEvent>();
        systemNotification.add(
            new BatchApexErrorEvent(
                message = 'Apex Batch Error'
            )
        );

        FW_SL_ErrorHandling errorHandling = new FW_SL_ErrorHandling(); 
        errorHandling = new FW_SL_ErrorHandling(errorRep);
        
        Id jobId = fflib_IDGenerator.generate(Job_Execution__c.sObjectType);
        errorHandling.writeLog(systemNotification.get(0),jobId);
        errorHandling.saveLogs();

        system.assertEquals(jobId, errorHandling.errorListToWrite[0].Job_Execution__c);
        system.assertEquals(1, errorHandling.errorListToWrite.size(), 'errorListToWrite with value:' + errorHandling.errorListToWrite.size());
    }

    @isTest
    private static void TestErrorCreation() {

        FW_IREP_ErrorLog errorRep = (FW_REP_ErrorLog)mocks.mock(FW_REP_ErrorLog.class);

        List<System_Notification__e> systemNotification = new List<System_Notification__e>();
        Id actorId = fflib_IDGenerator.generate(User.sObjectType);
        systemNotification.add(
            new System_Notification__e(
                Category__c = 'Apex Batch Error',
                Actor_Id__c = actorId
            )
        );

        systemNotification.add(
            new System_Notification__e(
                Category__c = 'Apex Batch Error'
            )
        );

        FW_SL_ErrorHandling errorHandling = new FW_SL_ErrorHandling(); 
        errorHandling = new FW_SL_ErrorHandling(errorRep);
        
        errorHandling.writeLog(systemNotification.get(0));
        errorHandling.saveLogs();

        system.assertEquals(actorId, errorHandling.errorListToWrite[0].Actor_Id__c);
        system.assertEquals(actorId, errorHandling.errorListToWrite[0].Actor_Name__c);
        system.assertEquals('Apex Batch Error', errorHandling.errorListToWrite[0].Category__c);
        
        errorHandling = new FW_SL_ErrorHandling(errorRep);

        errorHandling.writeLog(systemNotification.get(1));
        errorHandling.saveLogs();

        system.assertEquals(1, errorHandling.errorListToWrite.size(), 'errorListToWrite with value:' + errorHandling.errorListToWrite.size());
    }
}