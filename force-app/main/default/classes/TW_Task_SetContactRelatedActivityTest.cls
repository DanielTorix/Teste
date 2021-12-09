/**
@author Guilherme Charro
@date    12/11/2021
@description Test class for TW_Task_SetContactRelatedActivity
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                12/11/2021         Original Version                         100
*/
@isTest
private class TW_Task_SetContactRelatedActivityTest {
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

        List<Task> taskList = new List<Task>{
            new Task(
                Id = fflib_IDGenerator.generate(Task.sObjectType),
                WhoId = contactList[0].Id
            )
        };

        mocks.startStubbing();
        ((ISL_ContactRelatedActivity) mocks.doAnswer( new VoidAnswer(),contactRelatedActivity)).setContactRelatedActivity((Set<Id>)  fflib_match.anyObject());
        mocks.stopStubbing();

        TW_Task_SetContactRelatedActivity jobExecutionWorker = new TW_Task_SetContactRelatedActivity();
        jobExecutionWorker = new TW_Task_SetContactRelatedActivity(contactRelatedActivity);
        
        jobExecutionWorker.execute(taskList);

        ((ISL_ContactRelatedActivity)mocks.verify(contactRelatedActivity, 1)).setContactRelatedActivity((Set<Id>)  fflib_match.anyObject());
    }

    class VoidAnswer implements fflib_Answer {
        public Object answer (fflib_InvocationOnMock invocation) {
            return null;
        }
    }
}