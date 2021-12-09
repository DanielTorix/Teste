/**
@author Guilherme Charro 
@date   16/06/2021
@description Test class for TW_Case_CloseChildCases
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro              16/06/2021          Original Version                         unknown
Hugo Rodrigues                15/09/2021            updated class                           97
*/
@isTest
public class TW_Case_CloseChildCasesTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    private static void CaseCloseChildCasesTest(){
        IREP_Case caseRepository = (REP_Case)mocks.mock(REP_Case.class);
        ISL_ChatterNotifications caseChatterNotification = (SL_ChatterNotifications)mocks.mock(SL_ChatterNotifications.class);
        User testUser = new User(Id = fflib_IDGenerator.generate(User.sObjectType));
        List<Case> listCase = new List<Case>();
        List<Case> listCaseFinal = new List<Case>();
        Set<ID> caseIDSet = new Set<Id>();
        listCase.add(
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                Status = DO_Case.CASE_STATUS_CLOSED,
                OwnerId = testUser.Id,
                Source__c = Do_Case.CASE_SOURCE_OTHER,
                CategoryT1__c = Do_Case.CASE_CATEGORY1_SPAM,
                RecordTypeID= Do_Case.CASE_RECORDTYPEID_CASE
            )  
        );
        listCase.add(
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                Status = DO_Case.CASE_STATUS_COMPLETED,
                OwnerId = testUser.Id,
                Source__c = Do_Case.CASE_SOURCE_OTHER,
                CategoryT1__c = Do_Case.CASE_CATEGORY1_SPAM,
                RecordTypeID= Do_Case.CASE_RECORDTYPEID_CLAIM
            )  
        );
        
        listCase[0] = (Case)fflib_ApexMocksUtils.setReadOnlyFields(
            listCase[0],
            Case.class,
            new Map<SObjectField, Object> {Case.IsClosed => true}
        );
        listCase[1] = (Case)fflib_ApexMocksUtils.setReadOnlyFields(
            listCase[1],
            Case.class,
            new Map<SObjectField, Object> {Case.IsClosed => true}
        );
        
        Map<Id, Case> mapOldCases = new Map<Id, Case>();
        mapOldCases.put(listCase[0].Id, new Case(
            Id = fflib_IDGenerator.generate(Case.sObjectType),
            Status = Do_Case.CASE_STATUS_NEW,
            RecordTypeID= Do_Case.CASE_RECORDTYPEID_CASE
        ));
        mapOldCases.put(listCase[1].Id, new Case(
            Id = fflib_IDGenerator.generate(Case.sObjectType),
            Status = Do_Case.CASE_STATUS_NEW,
            RecordTypeID= Do_Case.CASE_RECORDTYPEID_CASE
        ));
        
        User runningUser = new User(Id = fflib_IDGenerator.generate(User.sObjectType));
        
        List<Case> listChildCases = new List<Case>();
        listChildCases.add(
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                ParentId = listCase[0].Id,
                Parent= listCase[0],
                OwnerId = runningUser.Id,
                Source__c = Do_Case.CASE_SOURCE_OTHER,
                CategoryT1__c = Do_Case.CASE_CATEGORY1_SPAM,
                RecordTypeID= Do_Case.CASE_RECORDTYPEID_CASE
            )  
        );
        listChildCases.add(
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                ParentId = listCase[1].Id,
                Parent= listCase[1],
                OwnerId = runningUser.Id,
                Source__c = Do_Case.CASE_SOURCE_OTHER,
                CategoryT1__c = Do_Case.CASE_CATEGORY1_SPAM,
                RecordTypeID= Do_Case.CASE_RECORDTYPEID_CLAIM
            )  
        );

        listCaseFinal.add(new Case(
            Id = listCase[0].Id,
            Status = DO_Case.CASE_STATUS_CLOSED,
            OwnerId = testUser.Id,
            Source__c = Do_Case.CASE_SOURCE_OTHER,
            CategoryT1__c = Do_Case.CASE_CATEGORY1_SPAM,
            RecordTypeID= Do_Case.CASE_RECORDTYPEID_CASE
            )  
        );
        listCaseFinal.add(new Case(
            Id = listCase[1].Id,
            Status = DO_Case.CASE_STATUS_COMPLETED,
            OwnerId = testUser.Id,
            Source__c = Do_Case.CASE_SOURCE_OTHER,
            CategoryT1__c = Do_Case.CASE_CATEGORY1_SPAM,
            RecordTypeID= Do_Case.CASE_RECORDTYPEID_CLAIM
            )  
        );
        listCaseFinal[0] = (Case)fflib_ApexMocksUtils.setReadOnlyFields(
            listCaseFinal[0],
            Case.class,
            new Map<SObjectField, Object> {Case.IsClosed => true}
        );
        listCaseFinal[1] = (Case)fflib_ApexMocksUtils.setReadOnlyFields(
            listCaseFinal[1],
            Case.class,
            new Map<SObjectField, Object> {Case.IsClosed => true}
        );
        caseIDSet.add(listCaseFinal[0].Id);
        caseIDSet.add(listCaseFinal[1].Id);
        mocks.startStubbing();
        mocks.when(caseRepository.getChildCases((Set<Id>) fflib_match.anyObject())).thenReturn(listCase);
        mocks.when(caseRepository.updateSObjects(listCase)).thenReturn(new List<Database.SaveResult>());
        ((ISL_ChatterNotifications) mocks.doAnswer( new VoidAnswer(),caseChatterNotification)).persistChatterPosts();
        mocks.stopStubbing();
        
        TW_Case_CloseChildCases jobExecutionWorker = new TW_Case_CloseChildCases();
        jobExecutionWorker = new TW_Case_CloseChildCases(caseRepository, caseChatterNotification);
        
        jobExecutionWorker.execute(listCase, mapOldCases);
        
        ((IREP_Case)mocks.verify(caseRepository, 1)).getChildCases((Set<Id>) fflib_match.eq(caseIDSet));
        ((IREP_Case)mocks.verify(caseRepository, 1)).updateSObjects((List<Case>)fflib_match.eq(listCaseFinal));

    }

    class VoidAnswer implements fflib_Answer {
        public Object answer (fflib_InvocationOnMock invocation) {
            return null;
        }
    }
}