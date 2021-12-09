/**
@description    worker class to fill Contact field RelatedActivityDate__c
@testClass      TW_Contact_SetContactRelatedActivityTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                10/11/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Contact_SetContactRelatedActivity {
    public void execute(List<Contact> contactList) {
        for (Contact contactInserted : contactList) {
            if (contactInserted.RecordTypeId == Do_Contact.CONTACT_RECORDTYPEID_CEPCARDS) {
                contactInserted.RelatedActivityDate__c = DATE.TODAY();
            }
        }
    }
}