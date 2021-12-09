@isTest
public  class TW_Lead_ChangeOwnerNotificationTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
   
    

    @isTest
    private static void TW_Lead_ChangeOwnerNotificationTest() {

        
        ISL_ChatterNotifications leadChatterNotification = (SL_ChatterNotifications)mocks.mock(SL_ChatterNotifications.class);
        User runningUser = new User(Id = fflib_IDGenerator.generate(User.sObjectType));
        User testUser = new User(Id = fflib_IDGenerator.generate(User.sObjectType));
        List<Lead> leadList = new List<Lead>();
        leadList.add(
            new Lead(
                Id = fflib_IDGenerator.generate(Lead.sObjectType),
                OwnerId = runningUser.Id
            )  
        );
        
        Map<Id, Lead> oldLeadsMap = new Map<Id, Lead>();
        oldLeadsMap.put(leadList[0].Id, new Lead(Id = fflib_IDGenerator.generate(Lead.sObjectType)));
        
        leadList[0].OwnerId=testUser.Id;
        
        mocks.startStubbing();
        ((ISL_ChatterNotifications) mocks.doAnswer( new VoidAnswer(),leadChatterNotification)).persistChatterPosts();
        mocks.stopStubbing();
       
        TW_Lead_ChangeOwnerNotification jobExecutionWorker = new TW_Lead_ChangeOwnerNotification();
        jobExecutionWorker = new TW_Lead_ChangeOwnerNotification(leadChatterNotification);
        
        jobExecutionWorker.execute(leadList, oldLeadsMap);
        
        }
        class VoidAnswer implements fflib_Answer {
            public Object answer (fflib_InvocationOnMock invocation) {
                return null;
            }
        }
}