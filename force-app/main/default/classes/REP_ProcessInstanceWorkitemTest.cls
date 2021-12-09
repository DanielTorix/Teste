@isTest
public class REP_ProcessInstanceWorkitemTest {
    @isTest
    static void ProcessInstanceWorkitemTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Quote> listQuote = FW_TestDataFactory.createQuote(1, true);
            
            
            
            test.startTest();
            REP_ProcessInstanceWorkitem processInstanceWorkitemRepository = new REP_ProcessInstanceWorkitem();
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setNextApproverIds(new List<Id> {runningUser.Id});
                req.setObjectId(listQuote[0].Id);

                //Submit the approval request
                Approval.ProcessResult result = Approval.process(req);
                List<ProcessInstanceWorkitem> processInstanceWorkitemList = processInstanceWorkitemRepository.processInstanceWorkitemByObjectID(new Set<ID> {listQuote[0].Id});
            test.stopTest();
            System.assertEquals(1, processInstanceWorkitemList.size());
           
        }
    }
}