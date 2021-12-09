/**
@author Guilherme Charro
@date    12/11/2021
@description Test class for TW_Contact_SetContactRelatedActivity
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                12/11/20211         Original Version                       100
*/
@isTest
private class TW_Contact_SetContactRelatedActivityTest {
    @isTest
    static void SetContactRelatedActivityTest() {
        List<Contact> contactList = new List<Contact>{
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType),
                RecordTypeID = Do_Contact.CONTACT_RECORDTYPEID_CEPCARDS
            )
        };
        
        TW_Contact_SetContactRelatedActivity jobExecutionWorker = new TW_Contact_SetContactRelatedActivity();
        jobExecutionWorker = new TW_Contact_SetContactRelatedActivity();
        jobExecutionWorker.execute(contactList);

        System.assertEquals(DATE.TODAY(), contactList[0].RelatedActivityDate__c, 'Expected today date');
    }
}