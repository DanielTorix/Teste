/**
@description    worker class to fill Contact field RelatedActivityDate__c
@testClass      TW_Event_SetContactRelatedActivityTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                10/11/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Event_SetContactRelatedActivity {
    private ISL_ContactRelatedActivity contactRelatedActivity;

    public TW_Event_SetContactRelatedActivity(){
        this.contactRelatedActivity = new SL_ContactRelatedActivity();
    }
    
    @TestVisible
    private TW_Event_SetContactRelatedActivity(ISL_ContactRelatedActivity contactRelatedActivity){
        this.contactRelatedActivity = contactRelatedActivity;
    }

    public void execute(List<Event> eventList) {
        Set<Id> contactIdSet = new Set<Id>();
        for (Event eventInserted : eventList) {
            if (!String.isBlank(eventInserted.WhoId) && Schema.Contact.SObjectType == eventInserted.WhoId.getSobjectType()) {
                contactIdSet.add(eventInserted.WhoId);
            }            
        }

        if (!contactIdSet.isEmpty()) {
            contactRelatedActivity.setContactRelatedActivity(contactIdSet);
        }
    }
}