/**
@author Guilherme Charro
@date   22/06/2021
@description Test class for TW_Case_HasOpenChildCases
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                22/06/2021         Original Version                         94
*/
@isTest
public with sharing class TW_Case_HasOpenChildCasesTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void TW_Case_HasOpenChildCasesTest() {
        IREP_Case caseRepository = (REP_Case)mocks.mock(REP_Case.class);
        IREP_CEPSkipValidationRules cepSkipValidationRulesRepository = (REP_CEPSkipValidationRules )mocks.mock(REP_CEPSkipValidationRules.class);

        CEPSkipValidationRules__c skipValidation = new CEPSkipValidationRules__c();
        insert skipValidation;

        List<Case> listCase = new List<Case>();
        listCase.add(
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                Status = DO_Case.CASE_STATUS_CLOSED
            )  
        );
        
        Map<Id, Case> mapOldCases = new Map<Id, Case>();
        mapOldCases.put(listCase[0].Id, new Case(Id = fflib_IDGenerator.generate(Case.sObjectType)));
        
        User runningUser = new User(Id = fflib_IDGenerator.generate(User.sObjectType));
        
        List<Case> listChildCases = new List<Case>();
        listChildCases.add(
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                ParentId = listCase[0].Id
            )  
        );
        
        List<Case> newListCases = new List<Case>();
        newListCases.add(
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType)
            )  
        );

        mocks.startStubbing();
        mocks.when(caseRepository.getChildCases((Set<Id>) fflib_match.anyObject())).thenReturn(listChildCases);
        mocks.when(caseRepository.getParentCase((Set<Id>) fflib_match.anyObject())).thenReturn(listCase);
        mocks.when(caseRepository.updateSObjects(listChildCases)).thenReturn(new List<Database.SaveResult>());
        mocks.when(cepSkipValidationRulesRepository.updateSObjects((List<CEPSkipValidationRules__c>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        mocks.stopStubbing();

        TW_Case_HasOpenChildCases jobExecutionWorker = new TW_Case_HasOpenChildCases();
        jobExecutionWorker = new TW_Case_HasOpenChildCases(caseRepository, cepSkipValidationRulesRepository);
        
        jobExecutionWorker.execute(listChildCases, null);
        
        ((IREP_Case)mocks.verify(caseRepository, 1)).getChildCases((Set<Id>) fflib_match.anyObject());
        ((IREP_Case)mocks.verify(caseRepository, 1)).getParentCase((Set<Id>) fflib_match.anyObject());
        ((IREP_Case)mocks.verify(caseRepository, 1)).updateSObjects((List<Case>) fflib_match.anyList());
        ((IREP_CEPSkipValidationRules)mocks.verify(cepSkipValidationRulesRepository, 2)).updateSObjects((List<CEPSkipValidationRules__c>) fflib_match.anyList());
    }
}