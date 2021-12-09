/**
@author Carolina Resende
@date   08/09/2021
@description Test class for TW_Invoice_FillComplementaryFields
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Carolina Resende                25/11/2021         Original Version                         100
*/
@isTest
public with sharing class TW_Invoice_FillComplementaryFieldsTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    @isTest
    static void fillComplementaryFieldsTest() {
        IREP_Account accountRepository = (REP_Account)mocks.mock(REP_Account.class);
        List<Account> accountList = new List<Account>{ 
            new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType),
                BillingEmail__c = 'Hade@gmail.com'
            )
        };

        List<Invoice__c> invoiceList = new List<Invoice__c>{ 
            new Invoice__c(
                Id = fflib_IDGenerator.generate(Invoice__c.sObjectType),
                Account__c = accountList[0].Id
            ),
            new Invoice__c( 
                Id = fflib_IDGenerator.generate(Invoice__c.sObjectType),
                Account__c = accountList[0].Id
            )
        };

        Map<Id, Account> accountMapById = new Map<Id, Account>(accountList);
        mocks.startStubbing();
        mocks.when(accountRepository.getAccountFromInvoice((Set<Id>) fflib_match.anyObject())).thenReturn(accountMapById);
        mocks.stopStubbing(); 

        TW_Invoice_FillComplementaryFields fillComplementaryFieldsWorker = new TW_Invoice_FillComplementaryFields();
        fillComplementaryFieldsWorker = new TW_Invoice_FillComplementaryFields(accountRepository);
        fillComplementaryFieldsWorker.execute(invoiceList);

        ((IREP_Account)mocks.verify(accountRepository, 1)).getAccountFromInvoice((Set<Id>) fflib_match.anyObject());
    } 
}