@isTest
private class FW_PlatformEventPublisherTest {

    @isTest
    private static void publishTest(){

        FW_PlatformEventPublisher platPublisher = new FW_PlatformEventPublisher();
        sObject batchErrorEvent = new BatchApexErrorEvent();
        Test.startTest();
            platPublisher = new FW_PlatformEventPublisher(new List<sObject>{batchErrorEvent});
            platPublisher.publish();
        Test.stopTest();
    }

    @isTest
    private static void publishWithErrorTest(){

        FW_PlatformEventPublisher platPublisher;
        BatchApexErrorEvent batchErrorEvent = new BatchApexErrorEvent();
        batchErrorEvent.AsyncApexJobId = fflib_IDGenerator.generate(Account.sObjectType);
        batchErrorEvent.Phase ='randomtext';
        Test.startTest();
            platPublisher = new FW_PlatformEventPublisher(new List<sObject>{batchErrorEvent});
            platPublisher.publish();
        Test.stopTest();
    }
}