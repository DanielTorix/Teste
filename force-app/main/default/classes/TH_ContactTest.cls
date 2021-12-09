/**
@author Guilherme Charro
@date    07/10/2021
@description Test class for TH_Contact
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                07/10/2021         Original Version                         100
*/
@isTest
public with sharing class TH_ContactTest {
    @isTest
    static void ContactTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Contact> contactList = FW_TestDataFactory.createContact(1, false);            
            
            User adminUser = FW_TestDataFactory.createUsers(1, false, 'System Administrator', null)[0];
            test.startTest();
            System.runAs(adminUser){
                insert contactList;
                contactList[0].LastName = 'XPTO 123';
                update contactList;
            }
            test.stopTest();
            System.assertNotEquals(null, contactList[0].Id);
        }
    }
}