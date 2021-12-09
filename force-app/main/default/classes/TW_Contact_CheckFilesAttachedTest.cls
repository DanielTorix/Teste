/**
@author Guilherme Charro
@date    08/10/2021
@description Test class for TW_Contact_CheckFilesAttached
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                08/10/2021         Original Version                         100
Hugo Rodrigues                28/10/2021          Updated to work with RecordType of Cards   100
*/
@isTest
private class TW_Contact_CheckFilesAttachedTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    static void TW_Contact_CheckFilesAttachedTest() {
        IREP_ContentDocumentLink contentDocumentRepository = (REP_ContentDocumentLink)mocks.mock(REP_ContentDocumentLink.class);

        List<Contact> contactList = new List<Contact>{
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType),
                ConfirmYouHaveWrittenConsent__c = true,
                RecordTypeID= Do_Contact.CONTACT_RECORDTYPEID_CEPCARDS
            ),
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType),
                ConfirmYouHaveWrittenConsent__c = true,
                RecordTypeID= Do_Contact.CONTACT_RECORDTYPEID_CEPCARDS
            )
        };

        Map<Id,Contact> oldContactMap = new Map<Id,Contact>();
        oldContactMap.put(contactList[0].Id, contactList[0]);

        List<ContentDocumentLink> documentList = new List<ContentDocumentLink>{
            new ContentDocumentLink(
                Id = fflib_IDGenerator.generate(ContentDocumentLink.sObjectType)
            ),
            new ContentDocumentLink(
                Id = fflib_IDGenerator.generate(ContentDocumentLink.sObjectType)
            )
        };

        documentList[0] = (ContentDocumentLink)fflib_ApexMocksUtils.setReadOnlyFields(
            documentList[0],
            ContentDocumentLink.class,
            new Map<SObjectField, Object> {ContentDocumentLink.LinkedEntityId => contactList[1].Id}
        );
        documentList[1] = (ContentDocumentLink)fflib_ApexMocksUtils.setReadOnlyFields(
            documentList[1],
            ContentDocumentLink.class,
            new Map<SObjectField, Object> {ContentDocumentLink.LinkedEntityId => contactList[1].Id}
        );

        oldContactMap.put(contactList[1].Id, contactList[1]);

        mocks.startStubbing();
        mocks.when(contentDocumentRepository.getFilesOnLead((Set<Id>)  fflib_match.anyObject())).thenReturn(documentList);
        mocks.stopStubbing();

        TW_Contact_CheckFilesAttached jobExecutionWorker = new TW_Contact_CheckFilesAttached();
        jobExecutionWorker = new TW_Contact_CheckFilesAttached(contentDocumentRepository);
        
        jobExecutionWorker.execute(contactList, oldContactMap);

        ((IREP_ContentDocumentLink)mocks.verify(contentDocumentRepository, 1)).getFilesOnLead((Set<Id>)  fflib_match.anyObject());
    }
}