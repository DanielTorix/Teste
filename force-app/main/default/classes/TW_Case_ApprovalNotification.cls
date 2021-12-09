/**
* @description   worker class to send notification on chatter to the Case owner when Approval Process changes
* @testClass     TW_Case_ApprovalNotificationTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               12/10/2021          Created Case Worker
* ------------------------------------------------------------------------------------ 
*/
public without sharing class TW_Case_ApprovalNotification {
   
    
    private ISL_ChatterNotifications caseChatterNotifications;
    
    //constructor
     public TW_Case_ApprovalNotification(){
         this.caseChatterNotifications = new SL_ChatterNotifications();
      
    }
    
    //to use on test
    @TestVisible
    private TW_Case_ApprovalNotification(ISL_ChatterNotifications caseChatterNotifications){
        this.caseChatterNotifications = caseChatterNotifications;
        
    }
    
    
    //method execute
    public void execute(List<Case> caseList, Map<Id,Case> caseOldMap) {
        //check all Cases in the List
        for(Case caseForNoitification : caseList){
            //if the Approval Status is changed
            if(caseForNoitification.ApprovalStatus__c != caseOldMap.get(caseForNoitification.Id).ApprovalStatus__c && caseForNoitification.ApprovalStatus__c!= null && caseForNoitification.ApprovalStatus__c != DO_Case.CASE_APPROVAL_STARTED){
                //add the text to send to the chatter
                SL_ChatterNotifications caseChatterNotificationPost = new SL_ChatterNotifications.chatterBuilder()
                .setPreText(' ')
                .setPosText(System.Label.CaseApprovalNotification + ' ' + caseForNoitification.CaseNumber + ' ' + System.Label.CaseApprovalNotification2 + ' ' + caseForNoitification.ApprovalStatus__c)
                .setMentionIds(new List<String>{caseForNoitification.OwnerId})
                .setSubjectId(caseForNoitification.Id)
                .build();
                caseChatterNotifications.addFeedItemInputList( caseChatterNotificationPost.getFeedItemInputList() );
            }
        }
        
        //to do the post
        caseChatterNotifications.persistChatterPosts();
        
    }

}