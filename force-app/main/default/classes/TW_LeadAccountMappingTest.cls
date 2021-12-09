/**
@author Hugo Rodrigues
@date   25/08/2021
@description Test class for TW_LeadAccountMapping
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues                  25/08/2021         Original Version                         100
Hugo Rodrigues                  13/10/2021         updated for optimization                 100
*/
@isTest
public with sharing class TW_LeadAccountMappingTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void TW_LeadAccountMappingTest() {
        IREP_Account accountRepository = (REP_Account)mocks.mock(REP_Account.class);
        List<Lead> leadList = new List<Lead>();
        List<Contact> contactList = new List<Contact>();
        Map<ID,Lead> leadMap = new Map<ID,Lead>();
        List<Account> accountList = new List<Account>();
        Set<ID> accountIDSet = new Set<ID>();
        accountList.add(new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType),
                Name = Do_Account.ACCOUNT_NAME_FOR_TEST,
                ExternalId__c=Do_Account.ACCOUNT_EXT_CUSTOMER_ID_FOR_TEST
            ));
        leadList.add(
            new Lead(
                Id = fflib_IDGenerator.generate(Lead.sObjectType),
                Company = Do_Lead.LEAD_COMPANY_TEST,
                LastName=Do_Lead.LEAD_CONTACT_LAST_NAME_TEST,
                Potential_Diesel_volume_kL_y__c=1,
                Potential_Gasoline_volume_kL_y__c=2,
                Lead_Category__c=Do_Lead.LEAD_CATEGORY_BULK,
                IsConverted = false,
                TradeRegistrationNumber__c=Do_Lead.LEAD_TRADE_REGISTRATION_NUMBER_TEST,
                VAT_Tax_Number__c=Do_Lead.LEAD_VAX_NUMBER_TEST
                
            )  
        ); 
       
        contactList.add(
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType),
                LastName=Do_Lead.LEAD_CONTACT_LAST_NAME_TEST,
                AccountId=accountList[0].id
                
                
            )  
        ); 
        
        accountIDSet.add(accountList[0].id);
        leadMap.put(leadList[0].Id, new Lead(
            Id = fflib_IDGenerator.generate(Lead.sObjectType),
            IsConverted = false
        ));

        leadList[0] = (Lead)fflib_ApexMocksUtils.setReadOnlyFields(
            leadList[0],
            Lead.class,
            new Map<SObjectField, Object> {Lead.IsConverted => true,
            Lead.ConvertedAccountId => accountList[0].id}
        );
        
        
        mocks.startStubbing();
        mocks.when(accountRepository.getAccountsById((Set<Id>) fflib_match.anyObject())).thenReturn(accountList);
        mocks.when(accountRepository.updateSObjects(accountList)).thenReturn(new List<Database.SaveResult>());
        mocks.stopStubbing();

        TW_LeadAccountMapping jobExecutionWorker = new TW_LeadAccountMapping();
        jobExecutionWorker = new TW_LeadAccountMapping(accountRepository);
        
        jobExecutionWorker.execute(leadList,leadMap);

        ((IREP_Account)mocks.verify(accountRepository, 1)).getAccountsById((Set<Id>) fflib_match.eq(accountIDSet));
        ((IREP_Account)mocks.verify(accountRepository, 1)).updateSObjects((List<Account>) fflib_match.eq(accountList));
    }
}