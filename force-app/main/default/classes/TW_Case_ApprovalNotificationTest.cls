@isTest
public  class TW_Case_ApprovalNotificationTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
   
    

    @isTest
    private static void TW_Case_ApprovalNotificationTest() {

        
        ISL_ChatterNotifications caseChatterNotification = (SL_ChatterNotifications)mocks.mock(SL_ChatterNotifications.class);
        User runningUser = new User(Id = fflib_IDGenerator.generate(User.sObjectType));
        User testUser = new User(Id = fflib_IDGenerator.generate(User.sObjectType));
        List<Case> caseList = new List<Case>();
        caseList.add(
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                OwnerId = runningUser.Id,
                Origin=DO_Case.CASE_ORIGIN_MANUAL
            )  
        );
        
        Map<Id, Case> oldCasesMap = new Map<Id, Case>();
        oldCasesMap.put(caseList[0].Id, new Case(Id = fflib_IDGenerator.generate(Case.sObjectType)));
        
        caseList[0].ApprovalStatus__c=DO_Case.CASE_APPROVAL_APPROVED;
        
        mocks.startStubbing();
        ((ISL_ChatterNotifications) mocks.doAnswer( new VoidAnswer(),caseChatterNotification)).persistChatterPosts();
        mocks.stopStubbing();
       
        TW_Case_ApprovalNotification jobExecutionWorker = new TW_Case_ApprovalNotification();
        jobExecutionWorker = new TW_Case_ApprovalNotification(caseChatterNotification);
        
        jobExecutionWorker.execute(caseList, oldCasesMap);
        
        }
        class VoidAnswer implements fflib_Answer {
            public Object answer (fflib_InvocationOnMock invocation) {
                return null;
            }
        }
}