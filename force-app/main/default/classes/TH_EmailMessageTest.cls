@isTest
public with sharing class TH_EmailMessageTest {
    @isTest
    static void TH_EmailMessageTest() {
        test.startTest();
        List<EmailMessage> listEmailMessages = FW_TestDataFactory.createEmailMessage(1, true);
        test.stopTest();
        System.assertNotEquals(null, listEmailMessages[0].Id);
    }
}