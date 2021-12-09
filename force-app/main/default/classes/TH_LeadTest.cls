@isTest
public class TH_LeadTest {
    @isTest
    static void LeadTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        User testUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Lead> leadList = FW_TestDataFactory.createLead(1, true);
            
            User adminUser = FW_TestDataFactory.createUsers(1, false, 'System Administrator', null)[0];
            test.startTest();
            System.runAs(adminUser){
                leadList[0].OwnerId = testUser.ID;
                update leadList;
            }
            test.stopTest();
            System.assertNotEquals(null, leadList[0].Id);
        }
    }
}