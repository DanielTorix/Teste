@isTest
public class FW_TH_BatchApexErrorEventTest {

    static testMethod void testBatchApexErrorEvent() {
        User adminUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null)[0];
        try {
            Test.startTest();
                System.runAs(adminUser){
                    FW_TestDataFactory.createBatchDefinition( 1, true);
                    FW_TestBatch tb = new FW_TestBatch();
                    Database.executeBatch(tb); 
                    Test.getEventBus().deliver();
                }
            Test.stopTest();
        } catch(System.MathException e){
            Test.getEventBus().deliver();
            FW_REP_ErrorLog errorLogRep = new FW_REP_ErrorLog();
            System.assertEquals(1, [SELECT Id FROM Error_Log__c].size());
        }
    }   
}