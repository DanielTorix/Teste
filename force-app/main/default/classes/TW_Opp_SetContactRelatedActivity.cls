/**
@description    worker class to fill Contact field RelatedActivityDate__c
@testClass      TW_Opp_SetContactRelatedActivityTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                09/11/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Opp_SetContactRelatedActivity {
    private IREP_OppContactRole opportunityContactRoleRepository;
    private ISL_ContactRelatedActivity contactRelatedActivity;

    public TW_Opp_SetContactRelatedActivity(){
        this.opportunityContactRoleRepository = new REP_OppContactRole();
        this.contactRelatedActivity = new SL_ContactRelatedActivity();
    }
    
    @TestVisible
    private TW_Opp_SetContactRelatedActivity(IREP_OppContactRole opportunityContactRoleRepository, ISL_ContactRelatedActivity contactRelatedActivity){
        this.opportunityContactRoleRepository = opportunityContactRoleRepository;
        this.contactRelatedActivity = contactRelatedActivity;
    }

    public void execute(List<Opportunity> opportunityList) {
        Set<Id> oppIdsSet = new Set<Id>();
        for (Opportunity opp : opportunityList) {
            oppIdsSet.add(opp.Id);
        }

        List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>();
        if (!oppIdsSet.isEmpty()) {
            oppContactRoleList = opportunityContactRoleRepository.getOppContactRoleByOppId(oppIdsSet);
        }

        Set<Id> contactIdSet = new Set<Id>();
        for (OpportunityContactRole oppContactRole : oppContactRoleList) {
            contactIdSet.add(oppContactRole.ContactId);
        }

        if (!contactIdSet.isEmpty()) {
            contactRelatedActivity.setContactRelatedActivity(contactIdSet);
        }
    }
}