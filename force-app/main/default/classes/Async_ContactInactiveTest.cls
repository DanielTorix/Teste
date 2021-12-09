/**
@author Guilherme Charro
@date    07/10/2021
@description Test class for Async_ContactInactive
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                   07/10/2021         Original Version                       100
*/
@isTest
private class Async_ContactInactiveTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    static void contactInactiveTest() {
        IREP_Contact contactRepository = (REP_Contact)mocks.mock(REP_Contact.class);
        ISL_ChatterNotifications contactChatterNotification = (SL_ChatterNotifications)mocks.mock(SL_ChatterNotifications.class);
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);
        IDO_Contact contactDomain = (DO_Contact)mocks.mock(DO_Contact.class);
        IREP_CEPSkipValidationRules cepSkipValidationRulesRepository = (REP_CEPSkipValidationRules)mocks.mock(REP_CEPSkipValidationRules.class);
        IREP_TriggerHandlerSettings triggerHandlerSettingsRepository = (REP_TriggerHandlerSettings)mocks.mock(REP_TriggerHandlerSettings.class);
            
        //Create Batch_Definition
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Batch_Name__c = 'BatchTest',
                Class_Name__c = 'Async_ContactInactive',
                Job_Size__c = 200,
                SObject_API_Name__c = 'Contact'
            )
        };
        //Create Parameters
        List<Parameters__c> parametersList = new List<Parameters__c>{
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = FW_AsyncHandler.DEFAULT_PARAMETER
            ),
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = 'Years',
                Value__c='-3'
            ),
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = 'Days',
                Value__c='7'
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

        Date yearsAgo = DATE.TODAY().addYears(-3);
        Date daysAgo = yearsAgo.addDays(7);
            
        List<Contact> contactList = new List<Contact>{
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType),
                RelatedActivityDate__c = yearsAgo
            ),
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType),
                RelatedActivityDate__c = daysAgo.addDays(-1)
            )
        };

        mocks.startStubbing();
        mocks.when(contactDomain.createContact((Id)  fflib_match.anyObject())).thenReturn(contactList[0]);
        ((ISL_ChatterNotifications) mocks.doAnswer( new VoidAnswer(),contactChatterNotification)).persistChatterPosts();
        mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
        mocks.when(jobExecutionRep.getJobExecutionByAsyncApexJobIdSet((Id)fflib_match.anyObject())).thenReturn(jobExecutionList);
        mocks.when(parameterRep.getParametersByParentId((Set<Id>)fflib_match.anyObject())).thenReturn(parametersList);
        mocks.when(cepSkipValidationRulesRepository.updateSObjects((List<CEPSkipValidationRules__c>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        mocks.when(triggerHandlerSettingsRepository.updateSObjects((List<FW_TriggerHandlerSettings__c>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        mocks.stopStubbing();
           
 
        Async_ContactInactive newBatchRun = new Async_ContactInactive();
        newBatchRun = new Async_ContactInactive(contactRepository, jobExecutionRep, parameterRep, contactChatterNotification, contactDomain, cepSkipValidationRulesRepository, triggerHandlerSettingsRepository);

        Database.executeBatch(newBatchRun);
        newBatchRun.setAsyncApexJobId(null);
        newBatchRun.execute(null, contactList);
        
        ((FW_IREP_JobExecution)mocks.verify(jobExecutionRep, 1)).getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject());
        ((FW_IREP_Parameters)mocks.verify(parameterRep, 1)).getParametersByParentId((Set<Id>)fflib_match.anyObject());
        ((IDO_Contact)mocks.verify(contactDomain, 1)).createContact((Id) fflib_match.anyObject());
        ((IREP_CEPSkipValidationRules)mocks.verify(cepSkipValidationRulesRepository, 2)).updateSObjects((List<CEPSkipValidationRules__c>) fflib_match.anyList());
        ((IREP_TriggerHandlerSettings)mocks.verify(triggerHandlerSettingsRepository, 2)).updateSObjects((List<FW_TriggerHandlerSettings__c>) fflib_match.anyList());
    }

    class VoidAnswer implements fflib_Answer {
        public Object answer (fflib_InvocationOnMock invocation) {
            return null;
        }
    }
}