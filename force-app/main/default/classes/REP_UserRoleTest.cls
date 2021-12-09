@isTest
public class REP_UserRoleTest {
    @isTest
    static void UserRoleTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<UserRole> listUserRole = FW_TestDataFactory.createUserRole(1, true);
            
            
            
            
            test.startTest();
            REP_UserRole userRoleRepository = new REP_UserRole();
            List<UserRole> userRoleList = userRoleRepository.getUsersRolesByRoleName(new Set<String> {listUserRole[0].DeveloperName});
            test.stopTest();
            System.assertEquals(1, userRoleList.size());
           
        }
    }
}