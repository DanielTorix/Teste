/**
@author Guilherme Charro
@date    12/11/2021
@description Test class for TW_Case_SetContactRelatedActivity
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                12/11/2021         Original Version                         100
*/
@isTest
private class TW_Case_SetContactRelatedActivityTest {
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

        List<Case> caseList = new List<Case>{
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                ContactId = contactList[0].Id
            )
        };

        mocks.startStubbing();
        ((ISL_ContactRelatedActivity) mocks.doAnswer( new VoidAnswer(),contactRelatedActivity)).setContactRelatedActivity((Set<Id>)  fflib_match.anyObject());
        mocks.stopStubbing();

        TW_Case_SetContactRelatedActivity jobExecutionWorker = new TW_Case_SetContactRelatedActivity();
        jobExecutionWorker = new TW_Case_SetContactRelatedActivity(contactRelatedActivity);
        
        jobExecutionWorker.execute(caseList);

        ((ISL_ContactRelatedActivity)mocks.verify(contactRelatedActivity, 1)).setContactRelatedActivity((Set<Id>)  fflib_match.anyObject());
    }

    class VoidAnswer implements fflib_Answer {
        public Object answer (fflib_InvocationOnMock invocation) {
            return null;
        }
    }
}