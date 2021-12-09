/**
@author Guilherme Charro
@date    12/11/2021
@description Test class for TW_Opp_SetContactRelatedActivity
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                12/11/2021         Original Version                         100
*/
@isTest
private class TW_Opp_SetContactRelatedActivityTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    static void SetContactRelatedActivityTest() {
        ISL_ContactRelatedActivity contactRelatedActivity = (SL_ContactRelatedActivity)mocks.mock(SL_ContactRelatedActivity.class);
        IREP_OppContactRole opportunityContactRoleRepository = (REP_OppContactRole)mocks.mock(REP_OppContactRole.class);

        List<Contact> contactList = new List<Contact>{
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType),
                RecordTypeID = Do_Contact.CONTACT_RECORDTYPEID_CEPCARDS
            )
        };

        List<Opportunity> oppList = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.sObjectType)
            )
        };

        List<OpportunityContactRole> oppContactList = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                Id = fflib_IDGenerator.generate(OpportunityContactRole.sObjectType),
                ContactId = contactList[0].Id,
                OpportunityId = oppList[0].Id
            )
        };

        mocks.startStubbing();
        ((ISL_ContactRelatedActivity) mocks.doAnswer( new VoidAnswer(),contactRelatedActivity)).setContactRelatedActivity((Set<Id>)  fflib_match.anyObject());
        mocks.when(opportunityContactRoleRepository.getOppContactRoleByOppId((Set<Id>) fflib_match.anyObject())).thenReturn(oppContactList);
        mocks.stopStubbing();

        TW_Opp_SetContactRelatedActivity jobExecutionWorker = new TW_Opp_SetContactRelatedActivity();
        jobExecutionWorker = new TW_Opp_SetContactRelatedActivity(opportunityContactRoleRepository, contactRelatedActivity);
        
        jobExecutionWorker.execute(oppList);

        ((ISL_ContactRelatedActivity)mocks.verify(contactRelatedActivity, 1)).setContactRelatedActivity((Set<Id>)  fflib_match.anyObject());
        ((IREP_OppContactRole)mocks.verify(opportunityContactRoleRepository, 1)).getOppContactRoleByOppId((Set<Id>)  fflib_match.anyObject());
    }

    class VoidAnswer implements fflib_Answer {
        public Object answer (fflib_InvocationOnMock invocation) {
            return null;
        }
    }
}