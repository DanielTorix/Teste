/**
* @description   worker class to send notification on chatter to the Lead owner when is changed
* @testClass     TW_Lead_ChangeOwnerNotificationTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               26/05/2021          Created Lead Worker
* ------------------------------------------------------------------------------------ 
*/
public without sharing class TW_Lead_ChangeOwnerNotification {
   
    
    private ISL_ChatterNotifications leadChatterNotifications;
    
    //constructor
     public TW_Lead_ChangeOwnerNotification(){
         this.leadChatterNotifications = new SL_ChatterNotifications();
      
    }
    
    //to use on test
    @TestVisible
    private TW_Lead_ChangeOwnerNotification(ISL_ChatterNotifications leadChatterNotifications){
        this.leadChatterNotifications = leadChatterNotifications;
        
    }
    
    
    //method execute
    public void execute(List<Lead> leadList, Map<Id,Lead> leadOldMap) {
        //check all Leads in the List
        for(Lead leadForNoitification : leadList){
            //if the owner changed
            if(leadForNoitification.OwnerId != leadOldMap.get(leadForNoitification.Id).OwnerId){
                //add the text to send to the chatter
                String leadName = leadForNoitification.FirstName != null ? leadForNoitification.FirstName + ' ' + leadForNoitification.LastName : leadForNoitification.LastName;
                SL_ChatterNotifications leadChatterNotificationPost = new SL_ChatterNotifications.chatterBuilder()
                .setPreText(System.Label.ChatterLeadMessage_1 +' ')
                .setPosText(' ' +  System.Label.ChatterLeadMessage2 + ' ' + leadName + ' ' + System.Label.ChatterLeadMessage3)
                .setMentionIds(new List<String>{leadForNoitification.OwnerId})
                .setSubjectId(leadForNoitification.Id)
                .build();
               
                leadChatterNotifications.addFeedItemInputList( leadChatterNotificationPost.getFeedItemInputList() );
            }
        }
        
        //to do the post
        leadChatterNotifications.persistChatterPosts();
        
    }

}