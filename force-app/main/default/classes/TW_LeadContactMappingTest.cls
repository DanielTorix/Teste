/**
@author Hugo Rodrigues
@date   13/10/2021
@description Test class for TW_LeadContactMapping
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues                  13/10/2021         Original Version                         100
*/
@isTest
public class TW_LeadContactMappingTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void  TW_LeadContactMappingTest() {

        IREP_Contact contactRepository = (REP_Contact)mocks.mock(REP_Contact.class);
        List<Lead> leadList = new List<Lead>();
        List<Contact> contactList = new List<Contact>();
        Map<ID,Lead> leadMap = new Map<ID,Lead>();
        List<Account> accountList = new List<Account>();
        Set<ID> contactsIdSet = new Set<ID>();
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
        
        contactsIdSet.add(contactList[0].id);
        leadMap.put(leadList[0].Id, new Lead(
            Id = fflib_IDGenerator.generate(Lead.sObjectType),
            IsConverted = false
        ));

        leadList[0] = (Lead)fflib_ApexMocksUtils.setReadOnlyFields(
            leadList[0],
            Lead.class,
            new Map<SObjectField, Object> {
                Lead.IsConverted => true,
                Lead.ConvertedContactId => contactList[0].id
            }
        );
        
        
        mocks.startStubbing();
        mocks.when(contactRepository.getContactById((Set<Id>) fflib_match.anyObject())).thenReturn(contactList);
        mocks.when(contactRepository.updateSObjects(contactList)).thenReturn(new List<Database.SaveResult>());
        mocks.stopStubbing();

        TW_LeadContactMapping jobExecutionWorker = new TW_LeadContactMapping();
        jobExecutionWorker = new TW_LeadContactMapping(contactRepository);
        
        jobExecutionWorker.execute(leadList,leadMap);

        ((IREP_Contact)mocks.verify(contactRepository, 1)).getContactById((Set<Id>) fflib_match.eq(contactsIdSet));
        ((IREP_Contact)mocks.verify(contactRepository, 1)).updateSObjects((List<Account>) fflib_match.eq(contactList));
    }
}