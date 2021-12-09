/**
* @description   Intervace class to send notification on chatter
* @testClass     SL_ChatterNotificationsTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
*Rodrigues, Hugo Alexandre      27/05/2021            Created class
* ------------------------------------------------------------------------------------ 
*/
public interface ISL_ChatterNotifications {
     // void persistChatterPosts(String communityId, List<ConnectApi.FeedItemInput> listFeedItemInput);
     void persistChatterPosts(String communityId );
     void persistChatterPosts();
     List<ConnectApi.FeedItemInput> getFeedItemInputList();
     void addFeedItemInputList( List<ConnectApi.FeedItemInput> newFeedItemInputList);
}