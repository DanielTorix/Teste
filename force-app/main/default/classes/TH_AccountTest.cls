@isTest
public with sharing class TH_AccountTest {
    @isTest
    static void TH_AccountTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Account> listAccounts = FW_TestDataFactory.createAccount(1, true);            
            
            User adminUser = FW_TestDataFactory.createUsers(1, false, 'System Administrator', null)[0];
            test.startTest();
            System.runAs(adminUser){
                listAccounts[0].Name = 'teste AccountTrigger';
                update listAccounts;
            }
            test.stopTest();
            System.assertNotEquals(null, listAccounts[0].Id);
        }
    }
}