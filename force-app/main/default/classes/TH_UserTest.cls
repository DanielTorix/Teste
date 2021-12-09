@isTest
public class TH_UserTest {
    @isTest
    static void userTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){            
            test.startTest();
                User adminUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null)[0];
            
            test.stopTest();
            System.assertEquals(false, adminUser.UserPreferencesDisableAllFeedsEmail);
        }
    }
}