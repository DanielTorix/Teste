/**
@author Carolina Resende
@date   28/11/2021
@description Test class for TW_Invoice_CreateNotification
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Carolina Resende                25/11/2021         Original Version                         100
Guilherme Charro				06/12/2021		   Edited notifications						96
*/

@isTest
public with sharing class TW_Invoice_CreateNotificationTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    private static void TW_Case_ApprovalNotificationTest() {
        ISL_ChatterNotifications contactChatterNotifications = (SL_ChatterNotifications)mocks.mock(SL_ChatterNotifications.class);
        IREP_User userRepository = (REP_User)mocks.mock(REP_User.class);
        IREP_Contact contactRepository = (REP_Contact)mocks.mock(REP_Contact.class);

        List<Account> accounttList = new List<Account>();
        accounttList.add(
            new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType)
            )  
        );
        List<Contact> contactList = new List<Contact>();
        contactList.add(
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType),
                OwnerId = fflib_IDGenerator.generate(User.sObjectType),
                AccountId = accounttList[0].Id,
                Account = accounttList[0]
            )  
        );
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        invoiceList.add(
            new Invoice__c(
                Id = fflib_IDGenerator.generate(Invoice__c.sObjectType),
                Account__c = accounttList[0].Id,
                Account__r = accounttList[0]
            )  
        ); 

        List<User> userList = new List<User>();
        userList.add(
            new User(
                Id = fflib_IDGenerator.generate(User.sObjectType),
                ContactId = contactList[0].Id,
                Contact = contactList[0]
            )  
        );

        mocks.startStubbing();
        mocks.when(contactRepository.getContactByAccountId((Set<Id>) fflib_match.anyObject())).thenReturn(contactList);
        mocks.when(userRepository.getPortalUsers((Set<Id>) fflib_match.anyObject())).thenReturn(userList);
        ((ISL_ChatterNotifications) mocks.doAnswer( new VoidAnswer(),contactChatterNotifications)).persistChatterPosts();
        mocks.stopStubbing();
       
        TW_Invoice_CreateNotification jobExecutionWorker = new TW_Invoice_CreateNotification();
        jobExecutionWorker = new TW_Invoice_CreateNotification(contactChatterNotifications, contactRepository, userRepository);
        
        jobExecutionWorker.execute(invoiceList);
        
        ((IREP_Contact)mocks.verify(contactRepository, 1)).getContactByAccountId((Set<Id>) fflib_match.anyObject());
        ((IREP_User)mocks.verify(userRepository, 1)).getPortalUsers((Set<Id>) fflib_match.anyObject());
    }

    class VoidAnswer implements fflib_Answer {
        public Object answer (fflib_InvocationOnMock invocation) {
            return null;
        }
    }
}