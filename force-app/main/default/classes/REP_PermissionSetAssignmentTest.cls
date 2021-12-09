@isTest
public class REP_PermissionSetAssignmentTest {
    @isTest
    static void PermissionSetAssignmentTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);

        List<String> permSetLabelList = new List<String>(); 
        REP_PermissionSetAssignment PermissionSetAssignmentRepository = new REP_PermissionSetAssignment();
        PermissionSetAssignment permAssign = FW_TestDataFactory.createAndAssignPermissionSetToUser(runningUser.Id);

        System.runAs(runningUser){  
            
            test.startTest();
                
                List<PermissionSetAssignment> permSetGroupAssignments = PermissionSetAssignmentRepository.getPermissionSetGroupsAssignedToUserByUserId( new Set<Id>{runningUser.Id}, new List<String>{'testFactory'} );
            test.stopTest();
            System.assertEquals( 1, permSetGroupAssignments.size() );
            
        }
    }
}