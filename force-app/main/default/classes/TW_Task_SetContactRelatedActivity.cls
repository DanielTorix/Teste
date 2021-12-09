/**
@description    worker class to fill Contact field RelatedActivityDate__c
@testClass      TW_Task_SetContactRelatedActivityTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                10/11/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Task_SetContactRelatedActivity {
    private ISL_ContactRelatedActivity contactRelatedActivity;

    public TW_Task_SetContactRelatedActivity(){
        this.contactRelatedActivity = new SL_ContactRelatedActivity();
    }
    
    @TestVisible
    private TW_Task_SetContactRelatedActivity(ISL_ContactRelatedActivity contactRelatedActivity){
        this.contactRelatedActivity = contactRelatedActivity;
    }

    public void execute(List<Task> taskList) {
        Set<Id> contactIdSet = new Set<Id>();
        for (Task taskInserted : taskList) {
            if (!String.isBlank(taskInserted.WhoId) && Schema.Contact.SObjectType == taskInserted.WhoId.getSobjectType()) {
                contactIdSet.add(taskInserted.WhoId);
            }            
        }

        if (!contactIdSet.isEmpty()) {
            contactRelatedActivity.setContactRelatedActivity(contactIdSet);
        }
    }
}