/**
@author Hugo Rodrigues  
@date   30/08/2021 
@description Test class for REP_User
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues             30/08/2021           Original Version                              unknown
João Alencar               22/09/2021    Added getUserAndAccountCountryAssociated Method      unknown
António Santos             03/11/2021    Replaced method to obtain portal user company code.  unknown
Hugo Rodrigues             02/12/2021   updated getPortalUserAndCompanyCode and getPortalUsers    100
*/@isTest
public class REP_UserTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    @isTest
    static void UserTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<UserRole> listUserRole = FW_TestDataFactory.createUserRole(1, true);

            runningUser.UserRoleId = listUserRole[0].id;
            update runningUser;
            
            test.startTest();
            REP_User userRepository = new REP_User();
            List<User> userByRoleList = userRepository.getUsersByRoleID(new Set<ID> {listUserRole[0].Id});
            List<User> userReturnedList = userRepository.getUsersByID(new Set<ID> {runningUser.id});
            List<User> userPortalList = userRepository.getPortalUserAndCompanyCode(new Set<ID> {runningUser.id});
            List<User> userPortalUserList = userRepository.getPortalUsers(new Set<ID> {fflib_IDGenerator.generate(Contact.sObjectType)});
            test.stopTest();
            System.assertEquals(1, userByRoleList.size());
            System.assertEquals(1, userReturnedList.size());
            System.assertEquals(1, userPortalList.size());
            System.assertEquals(0, userPortalUserList.size());
        }
    }
}