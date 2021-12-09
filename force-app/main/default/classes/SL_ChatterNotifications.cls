/**
* @description   class to send notification on chatter
* @testClass     SL_ChatterNotificationsTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
*Rodrigues, Hugo Alexandre      27/05/2021         Created class
*João Lopes                     28/05/2021         Changed class to meet project standard 
* ------------------------------------------------------------------------------------ 
*/
public with sharing class SL_ChatterNotifications implements ISL_ChatterNotifications{
    
    
    public List<ConnectApi.FeedItemInput> feedItemInputList = new List<ConnectApi.FeedItemInput>();
    //constructors
    public SL_ChatterNotifications(){}
    public SL_ChatterNotifications(SL_ChatterNotifications existingChatterPosts){
        this.feedItemInputList.addAll( existingChatterPosts.feedItemInputList );
    }
    public SL_ChatterNotifications( List<ConnectApi.FeedItemInput> feedItemInputList){
        this.feedItemInputList.addAll( feedItemInputList );
    }
    public SL_ChatterNotifications( ConnectApi.FeedItemInput feedItemInput ){
        this.feedItemInputList.add( feedItemInput );
    }

    //class to build the chat message
    public class chatterBuilder{
        private ConnectApi.TextSegmentInput preTextInput = new ConnectApi.TextSegmentInput();
        private ConnectApi.TextSegmentInput posTextInput = new ConnectApi.TextSegmentInput();
        private List<ConnectApi.MentionSegmentInput> mentionInputList = new List<ConnectApi.MentionSegmentInput>();
        private ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        private String recordSubjectId;
        private String communityId;

        public chatterBuilder(){}

        //method for Text before mention
        public chatterBuilder setPreText(String preText){
            this.preTextInput.text = preText;
            return this;
        }
        //method for Text after mention
        public chatterBuilder setPosText(String posText){
            this.posTextInput.text = posText;
            return this;
        }
        //method mention
        public chatterBuilder setMentionIds(List<String> mentionIdList){
            ConnectApi.MentionSegmentInput newMentionSegment = new ConnectApi.MentionSegmentInput();
            for(String userId : mentionIdList){
                newMentionSegment.id = userId;
            }
            this.mentionInputList.add(newMentionSegment);
            return this;
        }
        //method for link to the record
        public chatterBuilder setSubjectId(String recordId){
            this.recordSubjectId = recordId;
            return this;
        }
        //method to join everything
        public SL_ChatterNotifications build() {
            ConnectApi.MessageBodyInput bodyInput = new ConnectApi.MessageBodyInput();
    
            bodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

            if ( preTextInput.text != null) {
                bodyInput.messageSegments.add(preTextInput);    
            }
            if ( !mentionInputList.isEmpty() ) {
                bodyInput.messageSegments.addAll(mentionInputList);
            }
            
            if (posTextInput.text != null) {
                bodyInput.messageSegments.add(posTextInput);
            }
    
            this.feedItemInput.body = bodyInput;
            this.feedItemInput.subjectId = this.recordSubjectId;

            return new SL_ChatterNotifications( this.feedItemInput );
    
        }

    }
    //method to receive information to post
    private void persistChatterPostsPrivate( String communityId ){
        List<ConnectApi.BatchInput> chatterBatchInputList = new List<ConnectApi.BatchInput>();

        for(ConnectApi.FeedItemInput feeditem : this.feedItemInputList){
            chatterBatchInputList.add(new ConnectApi.BatchInput(feeditem));
        }
        if(!chatterBatchInputList.isEmpty() && !Test.isRunningTest()){
            ConnectApi.ChatterFeeds.postFeedElementBatch(communityId, chatterBatchInputList);
        }
    }

    //method to receive information to send to the private method
    public void persistChatterPosts(String communityId){
        persistChatterPostsPrivate( communityId );
    }
    public void persistChatterPosts(){
        persistChatterPostsPrivate( null );
    }
    public List<ConnectApi.FeedItemInput> getFeedItemInputList(){
        return this.feedItemInputList;
    }
    public void addFeedItemInputList( List<ConnectApi.FeedItemInput> newFeedItemInputList){
        this.feedItemInputList.addAll( newFeedItemInputList );
    }

}