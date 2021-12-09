/**
@author Guilherme Charro
@date    12/11/2021
@description Test class for TW_OppCont_SetContactRelatedActivity
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                12/11/2021         Original Version                         100
*/
@isTest
private class TW_OppCont_SetContactRelatedActivityTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    static void SetContactRelatedActivityTest() {
        ISL_ContactRelatedActivity contactRelatedActivity = (SL_ContactRelatedActivity)mocks.mock(SL_ContactRelatedActivity.class);

        List<Contact> contactList = new List<Contact>{
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType),
                RecordTypeID = Do_Contact.CONTACT_RECORDTYPEID_CEPCARDS
            )
        };

        List<OpportunityContactRole> oppContactList = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                Id = fflib_IDGenerator.generate(OpportunityContactRole.sObjectType),
                ContactId = contactList[0].Id
            )
        };

        mocks.startStubbing();
        ((ISL_ContactRelatedActivity) mocks.doAnswer( new VoidAnswer(),contactRelatedActivity)).setContactRelatedActivity((Set<Id>)  fflib_match.anyObject());
        mocks.stopStubbing();

        TW_OppCont_SetContactRelatedActivity jobExecutionWorker = new TW_OppCont_SetContactRelatedActivity();
        jobExecutionWorker = new TW_OppCont_SetContactRelatedActivity(contactRelatedActivity);
        
        jobExecutionWorker.execute(oppContactList);

        ((ISL_ContactRelatedActivity)mocks.verify(contactRelatedActivity, 1)).setContactRelatedActivity((Set<Id>)  fflib_match.anyObject());
    }

    class VoidAnswer implements fflib_Answer {
        public Object answer (fflib_InvocationOnMock invocation) {
            return null;
        }
    }
}