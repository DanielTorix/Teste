/**
@description    worker class to check if there are any child cases open
@testClass      TW_Case_OpenChildCasesTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                22/06/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Case_HasOpenChildCases {
    private IREP_Case caseRepository;
    private IREP_CEPSkipValidationRules cepSkipValidationRulesRepository;
    
    public TW_Case_HasOpenChildCases (){
        this.caseRepository = new REP_Case();
        this.cepSkipValidationRulesRepository = new REP_CEPSkipValidationRules();
    }
    
    @TestVisible
    private TW_Case_HasOpenChildCases (IREP_Case caseRepository, IREP_CEPSkipValidationRules cepSkipValidationRulesRepository){
        this.caseRepository = caseRepository;
        this.cepSkipValidationRulesRepository = cepSkipValidationRulesRepository;
    }
    
    public void execute(List<Case> caseList, Map<Id,Case> oldCaseMap) {
        Set<Id> parentCasesIds = new Set<Id>();
        for (Case caseUpdated : caseList) {
            if ((!String.isBlank(caseUpdated.ParentId) && oldCaseMap == null) || (!String.isBlank(caseUpdated.ParentId) && caseUpdated.Status != oldCaseMap.get(caseUpdated.Id).Status)) {
                parentCasesIds.add(caseUpdated.ParentId);
            }
        }

        List<Case> childCasesOpened = new List<Case>();
        List<Case> parentCases = new List<Case>();

        if (!parentCasesIds.isEmpty()) {
            childCasesOpened = caseRepository.getChildCases(parentCasesIds);
            parentCases = caseRepository.getParentCase(parentCasesIds);      
        }
        
        for (Case parentCase : parentCases) {
            Boolean isToUpdate = false;
            for (Case openChildCase : childCasesOpened) {
                if (openChildCase.ParentId == parentCase.Id) {
                    isToUpdate = true;
                    break;
                }
            }
            if (isToUpdate) {
                if (!parentCase.OpenChildCases__c) {
                    parentCase.OpenChildCases__c = true;
                }                
            }else{
                if (parentCase.OpenChildCases__c) {
                    parentCase.OpenChildCases__c = false;
                }
            }
        }

        if(!parentCases.isEmpty()){
            CEPSkipValidationRules__c skipValidation = CEPSkipValidationRules__c.getOrgDefaults();
            skipValidation.Case__c = true;
            cepSkipValidationRulesRepository.updateSObjects(new List<CEPSkipValidationRules__c>{skipValidation});

            caseRepository.updateSObjects(parentCases);         

            skipValidation.Case__c = false;
            cepSkipValidationRulesRepository.updateSObjects(new List<CEPSkipValidationRules__c>{skipValidation});
        }        
    }
}