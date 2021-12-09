/**
@description    worker class to fill Contact field RelatedActivityDate__c
@testClass      TW_OppCont_SetContactRelatedActivityTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                09/11/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_OppCont_SetContactRelatedActivity {
    private ISL_ContactRelatedActivity contactRelatedActivity;

    public TW_OppCont_SetContactRelatedActivity(){
        this.contactRelatedActivity = new SL_ContactRelatedActivity();
    }
    
    @TestVisible
    private TW_OppCont_SetContactRelatedActivity(ISL_ContactRelatedActivity contactRelatedActivity){
        this.contactRelatedActivity = contactRelatedActivity;
    }

    public void execute(List<OpportunityContactRole> opportunityContactRoleList) {
        Set<Id> contactIdSet = new Set<Id>();
        for (OpportunityContactRole oppContactRole : opportunityContactRoleList) {
            contactIdSet.add(oppContactRole.ContactId);
        }

        if (!contactIdSet.isEmpty()) {
            contactRelatedActivity.setContactRelatedActivity(contactIdSet);
        }
    }
}