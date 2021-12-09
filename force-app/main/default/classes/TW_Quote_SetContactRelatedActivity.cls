/**
@description    worker class to fill Contact field RelatedActivityDate__c
@testClass      TW_Quote_SetContactRelatedActivityTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                10/11/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Quote_SetContactRelatedActivity {
    private ISL_ContactRelatedActivity contactRelatedActivity;

    public TW_Quote_SetContactRelatedActivity(){
        this.contactRelatedActivity = new SL_ContactRelatedActivity();
    }
    
    @TestVisible
    private TW_Quote_SetContactRelatedActivity(ISL_ContactRelatedActivity contactRelatedActivity){
        this.contactRelatedActivity = contactRelatedActivity;
    }

    public void execute(List<Quote> quoteList) {
        Set<Id> contactIdSet = new Set<Id>();
        for (Quote quoteInserted : quoteList) {
            if (!String.isBlank(quoteInserted.ContactId)) {
                contactIdSet.add(quoteInserted.ContactId);
            }            
        }

        if (!contactIdSet.isEmpty()) {
            contactRelatedActivity.setContactRelatedActivity(contactIdSet);
        }
    }
}