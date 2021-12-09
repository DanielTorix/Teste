/**
@author Carolina Resende
@date   29/11/2021
@description Test class for Async_FPSInvoiceRemainder
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                  Date                Description                                  Coverage
----------------------------------------------------------------------------------------------------
Carolina Resende           29/11/2021         Original Version                                    100
Guilherme Charro	       06/12/2021         Edited notifications						          97
*/

@isTest
public with sharing class Async_FPSInvoiceRemainderTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    @isTest
    static void fpsInvoiceRemainderTest() {
        IREP_User userRepository = (REP_User)mocks.mock(REP_User.class);
        IREP_Contact contactRepository = (REP_Contact)mocks.mock(REP_Contact.class);
        ISL_ChatterNotifications invoiceChatterNotifications = (SL_ChatterNotifications)mocks.mock(SL_ChatterNotifications.class);
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);
        
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

        // Initialize framework        
        //Create Batch_Definition
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Batch_Name__c = 'BatchTest',
                Class_Name__c = 'Async_FPSInvoiceRemainder',
                Job_Size__c = 200,
                SObject_API_Name__c = 'Invoice__c'
                )
        };
        //Create Parameters
        List<Parameters__c> parametersList = new List<Parameters__c>{
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = FW_AsyncHandler.DEFAULT_PARAMETER
                ) 
        };

        //Create JobExecution
        List<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Run_With_Defaults__c = true              
                )
        };

        mocks.startStubbing(); 
        mocks.when(contactRepository.getContactByAccountId((Set<Id>) fflib_match.anyObject())).thenReturn(contactList);
        mocks.when(userRepository.getPortalUsers((Set<Id>) fflib_match.anyObject())).thenReturn(userList);
        ((ISL_ChatterNotifications) mocks.doAnswer( new VoidAnswer(),invoiceChatterNotifications)).persistChatterPosts();
        mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
        mocks.when(jobExecutionRep.getJobExecutionByAsyncApexJobIdSet((Id)fflib_match.anyObject())).thenReturn(jobExecutionList);
        mocks.when(parameterRep.getParametersByParentId((Set<Id>)fflib_match.anyObject())).thenReturn(parametersList);
        mocks.stopStubbing();
        

        Async_FPSInvoiceRemainder newBatchRun = new Async_FPSInvoiceRemainder();
        newBatchRun =new Async_FPSInvoiceRemainder(userRepository, contactRepository, jobExecutionRep, parameterRep, invoiceChatterNotifications);

        Database.executeBatch(newBatchRun);
        newBatchRun.setAsyncApexJobId(null);
        newBatchRun.execute(null, invoiceList);

        ((IREP_Contact)mocks.verify(contactRepository, 1)).getContactByAccountId((Set<Id>) fflib_match.anyObject());
        ((IREP_User)mocks.verify(userRepository, 1)).getPortalUsers((Set<Id>) fflib_match.anyObject());
    }
    class VoidAnswer implements fflib_Answer {
        public Object answer (fflib_InvocationOnMock invocation) {
            return null;
        }
    }
}