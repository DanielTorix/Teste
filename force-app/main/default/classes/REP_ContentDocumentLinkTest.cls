/**
@author Guilherme Charro
@date    08/10/2021
@description Test class for REP_ContentDocumentLink
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                08/10/2021         Original Version                         100
*/
@isTest
private class REP_ContentDocumentLinkTest {
    @isTest
    static void ContentDocumentLinkTest() {
        List<Contact> contactList = FW_TestDataFactory.createContact(1, true);

        List<ContentDocumentLink> documentLinkList = FW_TestDataFactory.createDocumentLink(1, true, contactList[0].Id);

        test.startTest();
        REP_ContentDocumentLink docLinkRepository = new REP_ContentDocumentLink();   
        List<ContentDocumentLink> docLinkReturnedList = docLinkRepository.getFilesOnLead(new Set<Id>{contactList[0].Id});
        test.stopTest();
        System.assertEquals(1, docLinkReturnedList.size());
    }
}