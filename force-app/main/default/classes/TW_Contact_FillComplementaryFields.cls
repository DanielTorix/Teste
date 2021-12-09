/**
@description    worker class to automatically fill needed fields
@testClass      TW_Contact_FillComplementaryFieldsTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* David Favinha                23/11/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Contact_FillComplementaryFields {
    public void execute(List<Contact> newContactList, Map<Id,Contact> oldContactMap) {
        for (Contact contactRecord : newContactList) {
            if(oldContactMap == null || oldContactMap.get(contactRecord.Id).Phone != contactRecord.Phone ||
                    oldContactMap.get(contactRecord.Id).OtherPhone != contactRecord.OtherPhone ||
                    oldContactMap.get(contactRecord.Id).MobilePhone != contactRecord.MobilePhone ){
                contactRecord.CTITechnicalPhone__c = contactRecord.Phone?.right(7);
                contactRecord.CTITechnicalOtherPhone__c = contactRecord.OtherPhone?.right(7);
                contactRecord.CTITechnicalMobilePhone__c = contactRecord.MobilePhone?.right(7);
            }
        }
    }
}