/**
@description    worker class to automatically fill Case Source
@testClass      TW_Case_FillComplementaryFieldsTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                22/06/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Case_FillComplementaryFields {    
    private ISL_CountryDefinitionFromParent countryDefinition;

    public TW_Case_FillComplementaryFields(){
        this.countryDefinition = new SL_CountryDefinitionFromParent();
    }
    
    @TestVisible
    private TW_Case_FillComplementaryFields(ISL_CountryDefinitionFromParent countryDefinition){
        this.countryDefinition = countryDefinition;
    }

    public void execute(List<Case> caseList, Map<Id,Case> oldCaseMap) {
        CEP_Configuration__c orgDefaults = CEP_Configuration__c.getOrgDefaults();
        List<String> allDomains = orgDefaults.OMVEmailDomains__c.split(',');
        List<Case> casesToFillCountryList = new List<Case>();

        for (Case caseInserted : caseList) {
            if (oldCaseMap == null) {
                if (!String.isBlank(caseInserted.ContactId)) {
                    caseInserted.Source__c = DO_Case.CASE_SOURCE_CUSTOMER_REPRESENTATIVE;
                }else{
                    if (caseInserted.Origin == DO_Case.CASE_ORIGIN_EMAIL && !String.isBlank(caseInserted.SuppliedEmail) && allDomains.contains(caseInserted.SuppliedEmail.substringAfter('@'))) {
                        caseInserted.Source__c = DO_Case.CASE_SOURCE_INTERNAL;
                    }
                }

                if (DO_Case.CASE_CARDS_RECORDTYPESIDS.contains(caseInserted.RecordTypeId) && 
                    !String.isBlank(caseInserted.AccountId)) {
                    casesToFillCountryList.add(caseInserted);
                }
            }else{
                if (DO_Case.CASE_CARDS_RECORDTYPESIDS.contains(caseInserted.RecordTypeId) && caseInserted.AccountId != oldCaseMap.get(caseInserted.Id).AccountId) {
                    casesToFillCountryList.add(caseInserted);
                }
                if( caseInserted.Status == DO_Case.CASE_STATUS_COMPLETED || caseInserted.Status == DO_Case.CASE_STATUS_CLOSED){
                    caseInserted.ReopenedInFlow__c = false;
                }
            }   
        }

        if (!casesToFillCountryList.isEmpty()) {
            countryDefinition.setCountryField(casesToFillCountryList, 'CompanyCodeCountry__c', 'AccountId');
        }        
    }
}