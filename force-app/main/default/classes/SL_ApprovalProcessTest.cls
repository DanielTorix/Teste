@isTest
public class SL_ApprovalProcessTest {
    /*
    @isTest
    public static void ApprovalProcessTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        
       
        System.runAs(runningUser){  
            test.startTest();
            User testUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
            User testUser2 = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
            List<Group> listGroup = FW_TestDataFactory.createGroup(1, true);
            List<GroupMember> listGroupMember = FW_TestDataFactory.createGroupMember(1, true,listGroup[0].id ,runningUser.id);
            List<GroupMember> listGroupMember2 = FW_TestDataFactory.createGroupMember(1, true,listGroup[0].id ,testUser.id);
            
            List<Quote> listQuote = FW_TestDataFactory.createQuote(1, true);
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new List<Id> {runningUser.Id});
            req.setObjectId(listQuote[0].Id);
            Approval.ProcessResult result = Approval.process(req);
            List<SL_ApprovalProcess.ApprovalInputs> inputsList = new List<SL_ApprovalProcess.ApprovalInputs>();
            SL_ApprovalProcess.ApprovalInputs inputs = new SL_ApprovalProcess.ApprovalInputs();
            inputs.groupID=listGroup[0].id;  
            inputs.actorID=runningUser.id;
            inputs.sObjectId=listQuote[0].id;
            inputs.action='Approve';
            inputs.stepNumber=2;
            inputsList.add(
                inputs
            );
            SL_ApprovalProcess.approvalProcess( inputsList );
            List<Quote> listQuote2 = FW_TestDataFactory.createQuote(1, true);
            Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
            req2.setComments('Approve.');
            req2.setNextApproverIds(new List<Id> {runningUser.Id});
            req2.setObjectId(listQuote2[0].Id);
            Approval.ProcessResult result2 = Approval.process(req2);
            List<SL_ApprovalProcess.ApprovalInputs> inputsList2 = new List<SL_ApprovalProcess.ApprovalInputs>();
            SL_ApprovalProcess.ApprovalInputs inputs2 = new SL_ApprovalProcess.ApprovalInputs();
            inputs2.groupID=listGroup[0].id;  
            inputs2.actorID=runningUser.id;
            inputs2.sObjectId=listQuote2[0].id;
            inputs2.action='Approve';
            inputs2.stepNumber=1;
            inputsList2.add(
                inputs2
            );
            SL_ApprovalProcess.approvalProcess( inputsList2 );
            List<Quote> listQuote3 = FW_TestDataFactory.createQuote(1, true);
            Approval.ProcessSubmitRequest req3 = new Approval.ProcessSubmitRequest();
            req3.setComments('Approve.');
            req3.setNextApproverIds(new List<Id> {runningUser.Id});
            req3.setObjectId(listQuote3[0].Id);
            Approval.ProcessResult result3 = Approval.process(req3);
            List<SL_ApprovalProcess.ApprovalInputs> inputsList3 = new List<SL_ApprovalProcess.ApprovalInputs>();
            SL_ApprovalProcess.ApprovalInputs inputs3 = new SL_ApprovalProcess.ApprovalInputs();
            inputs3.groupID=listGroup[0].id;  
            inputs3.actorID=runningUser.id;
            inputs3.sObjectId=listQuote3[0].id;
            inputs3.action='Reject';
            inputs3.stepNumber=2;
            inputsList3.add(
                inputs3
            );
            SL_ApprovalProcess.approvalProcess( inputsList3 );

            List<Quote> listQuote4 = FW_TestDataFactory.createQuote(1, true);
            
            Approval.ProcessSubmitRequest req4 = new Approval.ProcessSubmitRequest();
            req4.setComments('Approve.');
            req4.setNextApproverIds(new List<Id> {runningUser.Id});
            req4.setObjectId(listQuote4[0].Id);
            Approval.ProcessResult result4 = Approval.process(req4);
            List<SL_ApprovalProcess.ApprovalInputs> inputsList4 = new List<SL_ApprovalProcess.ApprovalInputs>();
            SL_ApprovalProcess.ApprovalInputs inputs4 = new SL_ApprovalProcess.ApprovalInputs();
            inputs4.groupID=listGroup[0].id;  
            inputs4.actorID=testUser.id;
            inputs4.sObjectId=listQuote4[0].id;
            inputs4.action='Approve';
            inputs4.stepNumber=2;
            inputsList4.add(
                inputs4
            );
            SL_ApprovalProcess.approvalProcess( inputsList4 );

            List<Quote> listQuote5 = FW_TestDataFactory.createQuote(1, true);
            Approval.ProcessSubmitRequest req5 = new Approval.ProcessSubmitRequest();
            req5.setComments('Approve.');
            req5.setNextApproverIds(new List<Id> {testUser2.Id});
            req5.setObjectId(listQuote5[0].Id);
            Approval.ProcessResult result5 = Approval.process(req5);
            List<SL_ApprovalProcess.ApprovalInputs> inputsList5 = new List<SL_ApprovalProcess.ApprovalInputs>();
            SL_ApprovalProcess.ApprovalInputs inputs5 = new SL_ApprovalProcess.ApprovalInputs();
            inputs5.groupID=listGroup[0].id;  
            inputs5.actorID=testUser.id;
            inputs5.sObjectId=listQuote5[0].id;
            inputs5.action='Approve';
            inputs5.stepNumber=1;
            inputsList5.add(
                inputs5
            );
            SL_ApprovalProcess.approvalProcess( inputsList5 );
            List<Quote> listQuote6 = FW_TestDataFactory.createQuote(1, true);
            Approval.ProcessSubmitRequest req6 = new Approval.ProcessSubmitRequest();
            req6.setComments('Approve.');
            req6.setNextApproverIds(new List<Id> {runningUser.Id});
            req6.setObjectId(listQuote6[0].Id);
            Approval.ProcessResult result6 = Approval.process(req6);
            List<SL_ApprovalProcess.ApprovalInputs> inputsList6 = new List<SL_ApprovalProcess.ApprovalInputs>();
            SL_ApprovalProcess.ApprovalInputs inputs6 = new SL_ApprovalProcess.ApprovalInputs();
            inputs6.groupID=listGroup[0].id;  
            inputs6.actorID=testUser.id;
            inputs6.sObjectId=listQuote6[0].id;
            inputs6.action='Reject';
            inputs6.stepNumber=2;
            inputsList6.add(
                inputs6
            );
            SL_ApprovalProcess.approvalProcess( inputsList6 );
            test.stopTest();
            
           
            
        }
    } 
    */
}