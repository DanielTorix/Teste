@isTest
public class SL_ApprovalProcessCreationTest {
    /*
    @isTest
    public static void ApprovalProcessCreationTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        
       
        System.runAs(runningUser){  
            test.startTest();
            
            List<UserRole> listUserRole = FW_TestDataFactory.createUserRole(1, true);
            
            runningUser.UserRoleId = listUserRole[0].id;
            update runningUser;
            List<Quote> listQuote = FW_TestDataFactory.createQuote(1, true);
            
            List<SL_ApprovalProcessCreation.ApprovalInputs> inputsList = new List<SL_ApprovalProcessCreation.ApprovalInputs>();
            SL_ApprovalProcessCreation.ApprovalInputs inputs = new SL_ApprovalProcessCreation.ApprovalInputs();
            inputs.roleID=listUserRole[0].id;  
            inputs.sObjectId=listQuote[0].id;
            inputsList.add(
                inputs
            );
            SL_ApprovalProcessCreation.initApprovalProcess( inputsList );
            
            test.stopTest();
            
           
            
        }
    }
    */
}