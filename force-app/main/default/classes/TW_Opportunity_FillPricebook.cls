/**
@description    worker class to fill Cards pricebook on Opportunity
@testClass      TW_Opportunity_FillPricebookTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                21/07/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Opportunity_FillPricebook {
    public void execute(List<Opportunity> opportunityList) {
        CEP_Configuration__c orgDefaults = CEP_Configuration__c.getOrgDefaults();
        Id pricebookId = orgDefaults.CardsPricebookId__c;
        for (Opportunity oppInserted : opportunityList) {
            if (oppInserted.RecordTypeId == DO_Opportunity.OPPORTUNITY_CARDS_RECORDTYPE_ID && !String.isBlank(pricebookId)) {
                oppInserted.Pricebook2Id = pricebookId;
            }
        }
    }
}