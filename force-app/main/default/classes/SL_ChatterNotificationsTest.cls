@isTest

public class SL_ChatterNotificationsTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
   
    

    @isTest
    public static void  SL_ChatterNotificationsTest() {

        ISL_ChatterNotifications chatterNotificationMock = (SL_ChatterNotifications)mocks.mock(SL_ChatterNotifications.class);
       

        mocks.startStubbing();
        ((ISL_ChatterNotifications) mocks.doAnswer( new VoidAnswer(),chatterNotificationMock)).persistChatterPosts();
        ((ISL_ChatterNotifications) mocks.doAnswer( new VoidAnswer(),chatterNotificationMock)).getFeedItemInputList();
        ((ISL_ChatterNotifications) mocks.doAnswer( new VoidAnswer(),chatterNotificationMock)).addFeedItemInputList(new List<ConnectApi.FeedItemInput>{});
        mocks.stopStubbing();

        SL_ChatterNotifications chatterNotification = new SL_ChatterNotifications();
        chatterNotification = new SL_ChatterNotifications.chatterBuilder()
        .setPreText('Hello ')
        .setPosText(', a new Lead: ')
        .setMentionIds(new List<String>{})
        .setSubjectId(null)
        .build();
        SL_ChatterNotifications chatterNotification2 = new SL_ChatterNotifications( chatterNotification );
        chatterNotification2 = new SL_ChatterNotifications.chatterBuilder()
        .setPreText('Hello ')
        .setPosText(', a new Lead: ')
        .setMentionIds( new List<String>{ UserInfo.getUserId() } )
        .setSubjectId(null)
        .build();
        SL_ChatterNotifications postNotification = new SL_ChatterNotifications( chatterNotification.getFeedItemInputList() );
        postNotification.addFeedItemInputList(chatterNotification.getFeedItemInputList());
        postNotification.persistChatterPosts();
        postNotification.addFeedItemInputList(chatterNotification2.getFeedItemInputList());
        postNotification.persistChatterPosts(null);
        postNotification.getFeedItemInputList();
        postNotification.persistChatterPosts();
    }

    class VoidAnswer implements fflib_Answer {
        public Object answer (fflib_InvocationOnMock invocation) {
            return null;
        }
    }
}