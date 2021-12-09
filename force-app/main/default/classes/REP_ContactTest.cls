/**
@author Hugo Rodrigues 
@date   13/10/2021 
@description Test class for REP_Contact
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues               13/10/2021           Original Version                         100
* Guilherme Charro           03/12/2021           Added getContactByAccountId              100
*/
@isTest
public class REP_ContactTest {
    @isTest
    static void ContactTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Contact> listContact = FW_TestDataFactory.createContacts(2, true);
            List<Account> listAccount = FW_TestDataFactory.createAccount(1, true);
            List<Contact> listContactWithAccount = FW_TestDataFactory.createContacts(1, false);
            listContactWithAccount[0].AccountId = listAccount[0].Id;
            insert listContactWithAccount;
            
            Set<Id> contactsIDSet = new Set<Id>();
            contactsIDSet.add(listContact[0].Id);
            contactsIDSet.add(listContact[1].Id);
            test.startTest();
                REP_Contact contactRepository = new REP_Contact();
                List<Contact> contactReturned = contactRepository.getContactById(contactsIDSet);
                List<Contact> contactReturnedWithAccount = contactRepository.getContactByAccountId(new Set<Id>{listAccount[0].Id});
            test.stopTest();
            System.assertEquals(2, contactReturned.size());
            System.assertEquals(1, contactReturnedWithAccount.size());
        }
    }
}