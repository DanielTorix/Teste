/**
@author Hugo Rodrigues  
@date   15/09/2021
@description Test class for TW_Case_UpdateWhenClosed
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues                15/09/2021          Original Version                         100
*/
@isTest
public class TW_Case_UpdateWhenClosedTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void CaseUpdateWhenClosedTest(){
        IREP_Case caseRepository = (REP_Case)mocks.mock(REP_Case.class);
       
        List<Case> listCase = new List<Case>();
        List<Case> listWithoutChildCase = new List<Case>();
        List<Case> listCaseFinal = new List<Case>();
        Set<ID> caseIDSet = new Set<Id>();
        listCase.add(
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                Status = DO_Case.CASE_STATUS_CLOSED,
                Source__c = Do_Case.CASE_SOURCE_OTHER,
                CategoryT1__c = Do_Case.CASE_CATEGORY1_SPAM,
                RecordTypeID= Do_Case.CASE_RECORDTYPEID_CASE
            )
        );
       

 
        Map<Id, Case> mapOldCases = new Map<Id, Case>();
        mapOldCases.put(listCase[0].Id, new Case(
            Id = fflib_IDGenerator.generate(Case.sObjectType),
            Status = Do_Case.CASE_STATUS_NEW
        ));
        
        
        User runningUser = new User(Id = fflib_IDGenerator.generate(User.sObjectType));
        
        List<Case> listChildCases = new List<Case>();
        listChildCases.add(
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                ParentId = listCase[0].Id,
                OwnerId = runningUser.Id,
                Source__c = Do_Case.CASE_SOURCE_OTHER,
                CategoryT1__c = Do_Case.CASE_CATEGORY1_SPAM
            )  
        );
        List<Case> newlistCases = (List<Case>)fflib_ApexMocksUtils.makeRelationship(
            List<Case>.class,
            listCase,
            Case.ParentId,
            new List<List<Case>> {listChildCases}
        );
        listWithoutChildCase.add(
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                Status = DO_Case.CASE_STATUS_CLOSED,
                Source__c = Do_Case.CASE_SOURCE_OTHER,
                CategoryT1__c = Do_Case.CASE_CATEGORY1_SPAM,
                RecordTypeID= Do_Case.CASE_RECORDTYPEID_CASE
            )
        );
        mapOldCases.put(listWithoutChildCase[0].Id, new Case(
            Id = fflib_IDGenerator.generate(Case.sObjectType),
            Status = Do_Case.CASE_STATUS_NEW
        ));
        newlistCases.addAll(listWithoutChildCase);

        listCaseFinal.add(
            new Case(
                Id = listCase[0].Id,
                Status = DO_Case.CASE_STATUS_CLOSED,
                Source__c = Do_Case.CASE_SOURCE_OTHER,
                CategoryT1__c = Do_Case.CASE_CATEGORY1_SPAM,
                RecordTypeID= Do_Case.CASE_RECORDTYPEID_CASE,
                ClosureReason__c=DO_Case.CASE_CLOSURE_REASON_COMPLETED_PARENT
            )
        );
        listCaseFinal.add(
            new Case(
                Id = listCase[0].Id,
                Status = DO_Case.CASE_STATUS_CLOSED,
                Source__c = Do_Case.CASE_SOURCE_OTHER,
                CategoryT1__c = Do_Case.CASE_CATEGORY1_SPAM,
                RecordTypeID= Do_Case.CASE_RECORDTYPEID_CASE,
                ClosureReason__c=DO_Case.CASE_CLOSURE_REASON_COMPLETED_NORMALLY
            )
        );
        Map<Id, Case> mapNewCase = new Map<Id, Case>(newlistCases);
        caseIDSet.add(listCaseFinal[0].Id);
        caseIDSet.add(listWithoutChildCase[0].Id);
        mocks.startStubbing();
        mocks.when(caseRepository.getCaseWithChildCasesById((Set<Id>) fflib_match.anyObject())).thenReturn(newlistCases);
        mocks.stopStubbing();
        
        TW_Case_UpdateWhenClosed jobExecutionWorker = new TW_Case_UpdateWhenClosed();
        jobExecutionWorker = new TW_Case_UpdateWhenClosed(caseRepository);
        
        jobExecutionWorker.execute(mapNewCase, mapOldCases);
        
        ((IREP_Case)mocks.verify(caseRepository, 1)).getCaseWithChildCasesById((Set<Id>) fflib_match.eq(caseIDSet));

        System.assertEquals(DO_Case.CASE_CLOSURE_REASON_COMPLETED_PARENT, mapNewCase.get(listCase.get(0).Id).ClosureReason__c);
        System.assertEquals(DO_Case.CASE_CLOSURE_REASON_COMPLETED_NORMALLY, mapNewCase.get(listWithoutChildCase.get(0).Id).ClosureReason__c);
    }
    

}