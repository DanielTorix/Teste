/**
@author Guilherme Charro
@date    08/10/2021
@description Test class for TW_Lead_CheckFilesAttached
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                08/10/2021         Original Version                         100
*/
@isTest
private class TW_Lead_CheckFilesAttachedTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    static void TW_Lead_CheckFilesAttachedTest() {
        IREP_ContentDocumentLink contentDocumentRepository = (REP_ContentDocumentLink)mocks.mock(REP_ContentDocumentLink.class);

        List<Lead> leadList = new List<Lead>{
            new Lead(
                Id = fflib_IDGenerator.generate(Lead.sObjectType),
                ConfirmYouHaveWrittenConsent__c = true
            ),
            new Lead(
                Id = fflib_IDGenerator.generate(Lead.sObjectType),
                ConfirmYouHaveWrittenConsent__c = true
            )
        };

        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        oldLeadMap.put(leadList[0].Id, leadList[0]);

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
            new Map<SObjectField, Object> {ContentDocumentLink.LinkedEntityId => leadList[1].Id}
        );
        documentList[1] = (ContentDocumentLink)fflib_ApexMocksUtils.setReadOnlyFields(
            documentList[1],
            ContentDocumentLink.class,
            new Map<SObjectField, Object> {ContentDocumentLink.LinkedEntityId => leadList[1].Id}
        );

        oldLeadMap.put(leadList[1].Id, leadList[1]);

        mocks.startStubbing();
        mocks.when(contentDocumentRepository.getFilesOnLead((Set<Id>)  fflib_match.anyObject())).thenReturn(documentList);
        mocks.stopStubbing();

        TW_Lead_CheckFilesAttached jobExecutionWorker = new TW_Lead_CheckFilesAttached();
        jobExecutionWorker = new TW_Lead_CheckFilesAttached(contentDocumentRepository);
        
        jobExecutionWorker.execute(leadList, oldLeadMap);

        ((IREP_ContentDocumentLink)mocks.verify(contentDocumentRepository, 1)).getFilesOnLead((Set<Id>)  fflib_match.anyObject());
    }
}