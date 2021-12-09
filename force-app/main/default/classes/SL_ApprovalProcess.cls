/**
* @description   Service class to send the Quote to Apporval
* @testClass     SL_ApprovalProcessTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               30/08/2021          Created Quote Service
* ------------------------------------------------------------------------------------ 
*/

public with sharing class SL_ApprovalProcess {
/*
    //Helper method to create new Process Work Item Request record to process an approval request after it is submitted.
    private static Approval.ProcessWorkitemRequest createProcessWorkItemRequest(Id approvalStepId, Id approverId, String approvalAction, String commentFromApprover){
        Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
        result.setComments(commentFromApprover);
        result.setAction(approvalAction);
        result.setWorkitemId(approvalStepId);
        if (approverId != null) {
            result.setNextApproverIds(new List<Id>{approverId});
        }
        return result;
    }   

    @InvocableMethod
    public static void approvalProcess(ApprovalInputs[] flowInputs) {

        //interface definition
        IREP_ProcessInstanceWorkitem processInstanceWorkitemRepository = new REP_ProcessInstanceWorkitem();
        IREP_User userRepository = new REP_User();
        IREP_Group groupRepository = new REP_Group();
        IREP_GroupMember groupMembersRepository = new REP_GroupMember();
        //variable definition
        List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
        Set<ID> userIDSet = New Set<ID>();
        Set<ID> groupIDSet = New Set<ID>();
        Set<ID> objectIDSet = New Set<ID>();
        String actionTobeUsed;
        Boolean oneApprovalneed =true;

        //get groupID and ObjectID
        for(ApprovalInputs approvalinput: flowInputs){

            groupIDSet.add(approvalinput.groupID);
            objectIDSet.add(approvalinput.sObjectId);
        }
        //get users inside the group members
        for(GroupMember groupMemberRecord:groupMembersRepository.getUserByGroupID(groupIDSet)){

            userIDSet.add(groupMemberRecord.UserOrGroupId);
        }
        //get all users
        List<User> userList = userRepository.getUsersByID(userIdSet);
        for(ApprovalInputs approvalinput: flowInputs){
            
            actionTobeUsed=approvalinput.action;
            //check if there was already one step or not
            if(approvalinput.stepNumber ==2){
                //if action is Approve
                if (approvalinput.action == Do_ProcessInstanceWorkitem.ACTION_APPROVE) {

                    for (ProcessInstanceWorkitem workItem : processInstanceWorkitemRepository.processInstanceWorkitemByObjectID(objectIDSet)) {
                        //if it already approved or not and if is the right user
                        if(oneApprovalneed && approvalinput.actorID ==workItem.actorID){

                            oneApprovalneed=false;
                            for (User userRecord : userList) {

                                approvalinput.action =Do_ProcessInstanceWorkitem.ACTION_APPROVE;
                                approvalRequestList.add(createProcessWorkItemRequest(workItem.Id,userRecord.Id, approvalinput.action, approvalinput.commentFromApprover));
                            }
                        }else{

                            approvalinput.action =Do_ProcessInstanceWorkitem.ACTION_REMOVE;
                            approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, workItem.actorID, approvalinput.action, approvalinput.commentFromApprover));                
                        }                       
                    }  
                }else if (approvalinput.action == Do_ProcessInstanceWorkitem.ACTION_REJECT || approvalinput.action == Do_ProcessInstanceWorkitem.ACTION_REMOVE) {
                     //if action isn't approve this part will run
                    for (ProcessInstanceWorkitem workItem : processInstanceWorkitemRepository.processInstanceWorkitemByObjectID(objectIDSet)) {

                        if(oneApprovalneed && approvalinput.actorID ==workItem.actorID){

                            oneApprovalneed=false;
                            approvalinput.action=actionTobeUsed;
                            approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, workItem.actorID, approvalinput.action, approvalinput.commentFromApprover));
                        }else{

                            approvalinput.action =Do_ProcessInstanceWorkitem.ACTION_REMOVE;
                            approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, workItem.actorID, approvalinput.action, approvalinput.commentFromApprover));
                            
                        }
                    }
                }
            }else{
                //if is the second time getting the approval
                for (ProcessInstanceWorkitem workItem : processInstanceWorkitemRepository.processInstanceWorkitemByObjectID(objectIDSet)) {

                    if(approvalinput.actorID ==workItem.actorID){
                        
                        approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, null, approvalinput.action, approvalinput.commentFromApprover));
                    }else if(approvalinput.stepNumber ==1){
                        
                        approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, null, Do_ProcessInstanceWorkitem.ACTION_REMOVE, approvalinput.commentFromApprover));
                    }
                }
            }
        }
        if(!approvalRequestList.isEmpty()){ 

            Approval.process(approvalRequestList);
        }
    }

    public class ApprovalInputs{

        @InvocableVariable
        public String comments;
        @InvocableVariable
        public ID groupID;
        @InvocableVariable
        public ID actorID;
        @InvocableVariable
        public Id sObjectId ;
        @InvocableVariable
        public Id roleID ;
        @InvocableVariable
        public String commentFromApprover;
        @InvocableVariable
        public String action;
        @InvocableVariable
        public Integer stepNumber;
    }

   */
}