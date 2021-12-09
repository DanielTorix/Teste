/**
* @description   worker class to Create the Approval process on the quote
* @testClass     SL_ApprovalProcessCreationTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               31/08/2021          Created Quote Worker
* ------------------------------------------------------------------------------------ 
*/
public with sharing class SL_ApprovalProcessCreation {
/*
    @InvocableMethod
    public static void initApprovalProcess(ApprovalInputs[] flowInputs) {
        //interface definition
        REP_User userRepository = new REP_User();
        //variable definition
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        Set<ID> userIDSet = New Set<ID>();
        Set<String> roleNameSet= new Set<String>();
        Set<ID> roleIDSet = New Set<ID>();
        //get roleID
        for(ApprovalInputs approvalinput:flowInputs){

            roleIDSet.add(approvalinput.roleID);
        }
        //get Users by Role ID
        List<User> userList = userRepository.getUsersByRoleID(roleIDSet);
        for(ApprovalInputs approvalInputRecord : flowInputs){

            for (User userRecord : userList) {

                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                approvalRequest.setComments(approvalInputRecord.comments);
                approvalRequest.setObjectId(approvalInputRecord.sObjectId);
                approvalRequest.setNextApproverIds(new List<Id>{userRecord.Id});
                approvalRequestList.add(approvalRequest);
            }
        }
        Approval.process(approvalRequestList);
    }
    
    public class ApprovalInputs{

        @InvocableVariable
        public String comments;
        @InvocableVariable
        public String groupName;
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