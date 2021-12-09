/**
@author 
@date  
@description Test class for REP_Account
@TestClass         
Modification Log:
* ----------------------------------------------------------------------------------------------------------
* Developer                       Date                Description                               Coverage
* Carolina Resende               30/11/2021          Add getAccountFromInvoice                  100%
* Carolina Resende               30/11/2021          Add getAccountWithContactsFromInvoice      100%
* ---------------------------------------------------------------------------------------------------------- 
*/
@isTest
public class REP_AccountTest {
    @isTest
    static void AccountTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Account> listAccounts = FW_TestDataFactory.createAccount(1, true);
           
            
            Set<Id> accountIDSet = new Set<Id>();
            accountIDSet.add(listAccounts[0].Id);
            
            test.startTest();
                REP_Account accountRepository = new REP_Account();
                List<Account> accountsReturned = accountRepository.getAccountsById(accountIDSet);
                List<Account> accountsReturned2 = accountRepository.getAccountCompanyCode(accountIDSet);
                Map<Id,Account> accountsReturned3 = accountRepository.getAccountFromInvoice(accountIDSet);
                
            test.stopTest();
            System.assertEquals(1, accountsReturned.size());
            System.assertEquals(1, accountsReturned2.size());
            System.assertEquals(1, accountsReturned3.values().size());
        }
    }
}