@isTest
public class TH_CaseTest {    
    @isTest
    static void CaseTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Case> listCases = FW_TestDataFactory.createCase(1, true);            
            
            User adminUser = FW_TestDataFactory.createUsers(1, false, 'System Administrator', null)[0];
            test.startTest();
            System.runAs(adminUser){
                listCases[0].Status = DO_Case.CASE_STATUS_CLOSED;
                update listCases;
            }
            test.stopTest();
            System.assertNotEquals(null, listCases[0].Id);
        }
    }
}