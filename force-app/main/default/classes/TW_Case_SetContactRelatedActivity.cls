/**
@description    worker class to fill Contact field RelatedActivityDate__c
@testClass      TW_Case_SetContactRelatedActivityTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                10/11/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Case_SetContactRelatedActivity {
    private ISL_ContactRelatedActivity contactRelatedActivity;

    public TW_Case_SetContactRelatedActivity(){
        this.contactRelatedActivity = new SL_ContactRelatedActivity();
    }
    
    @TestVisible
    private TW_Case_SetContactRelatedActivity(ISL_ContactRelatedActivity contactRelatedActivity){
        this.contactRelatedActivity = contactRelatedActivity;
    }

    public void execute(List<Case> caseList) {
        Set<Id> contactIdSet = new Set<Id>();
        for (Case caseInserted : caseList) {
            if (!String.isBlank(caseInserted.ContactId)) {
                contactIdSet.add(caseInserted.ContactId);
            }            
        }

        if (!contactIdSet.isEmpty()) {
            contactRelatedActivity.setContactRelatedActivity(contactIdSet);
        }
    }
}