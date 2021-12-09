/**
@description    worker class to automatically fill needed fields
@testClass      TW_Opp_FillComplementaryFieldsTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                09/09/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Opp_FillComplementaryFields {
    private ISL_CountryDefinitionFromParent countryDefinition;

    public TW_Opp_FillComplementaryFields(){
        this.countryDefinition = new SL_CountryDefinitionFromParent();
    }
    
    @TestVisible
    private TW_Opp_FillComplementaryFields(ISL_CountryDefinitionFromParent countryDefinition){
        this.countryDefinition = countryDefinition;
    }

    public void execute(List<Opportunity> oppList, Map<Id,Opportunity> oldOppMap) {
        List<Opportunity> oppToFillCountryList = new List<Opportunity>();

        for (Opportunity oppInserted : oppList) {
            if (oldOppMap == null) {
                if (oppInserted.RecordTypeId == DO_Opportunity.OPPORTUNITY_CARDS_RECORDTYPE_ID && !String.isBlank(oppInserted.AccountId)) {
                    oppToFillCountryList.add(oppInserted);
                }
            }else{
                if (oppInserted.RecordTypeId == DO_Opportunity.OPPORTUNITY_CARDS_RECORDTYPE_ID && oppInserted.AccountId != oldOppMap.get(oppInserted.Id).AccountId) {
                    oppToFillCountryList.add(oppInserted);
                }
            }   
        }

        if (!oppToFillCountryList.isEmpty()) {
            countryDefinition.setCountryField(oppToFillCountryList, 'CompanyCodeCountry__c', 'AccountId');
        }        
    }
}