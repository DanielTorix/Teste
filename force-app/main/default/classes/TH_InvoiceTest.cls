@isTest
public with sharing class TH_InvoiceTest {
    @isTest
    static void invoiceTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Account> listAccounts = FW_TestDataFactory.createAccount(1, true);            
            test.startTest();
            List<Invoice__c> listInvoices = FW_TestDataFactory.createInvoice(listAccounts[0], 1, true);
            test.stopTest();
            System.assertNotEquals(null, listAccounts[0].Id);
        }
    }
}