/**
@author Hugo Rodrigues
@date   23/06/2021
@description Test class for Async_OppNotClosedNotification
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                  Date                Description                                  Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues           23/06/2021            Original Version                                 100
Hugo Rodrigues           23/09/2021   added RecordType and 2 updates because validation rule    100
Guilherme Charro         26/11/2021            edited to use framework                           95
*/
@isTest
public class Async_OppNotClosedNotificationTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    @isTest
    static void Async_OpportunityNotClosedNotificationExecute() {
        IREP_Opportunity opportunityRepository = (REP_Opportunity)mocks.mock(REP_Opportunity.class);
        ISL_ChatterNotifications opportunityChatterNotification = (SL_ChatterNotifications)mocks.mock(SL_ChatterNotifications.class);
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);

        List<Account> objListAccount = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType),
                Name = Do_Account.ACCOUNT_NAME_FOR_TEST,
                ExternalId__c = Do_Account.ACCOUNT_EXT_CUSTOMER_ID_FOR_TEST
            )
        };

        List<Opportunity> opportunitiesList = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.sObjectType),
                Name = Do_Opportunity.OPPORTUNITY_NAME_FOR_TEST,
                AccountId=objListAccount[0].Id,
                CloseDate=System.today().addMonths(1),
                StageName=Do_Opportunity.OPPORTUNITY_STAGENAME_QUALIFICATION,
                OpportunityCategory__c=Do_Opportunity.OPPORTUNITY_CATEGORY_CARDS
            )
        };
            
        opportunitiesList[0] = (Opportunity)fflib_ApexMocksUtils.setReadOnlyFields(
            opportunitiesList[0],
            Opportunity.class,
            new Map<SObjectField, Object> {Opportunity.CreatedDate => System.today().addDays(-1)}
        );
        
        List<Quote> objListQuote = new List<Quote>{
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                Name = DO_Quote.QUOTE_NAME_FOR_TEST,
                OpportunityID =opportunitiesList[0].Id,
                ClosedDate__c = date.Today(),
                RecordTypeID=DO_Quote.QUOTE_CARDS_RECORDTYPE_ID,
                Status=DO_Quote.QUOTE_STATUS_ACCEPTED
            ),
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                Name = DO_Quote.QUOTE_NAME_FOR_TEST,
                OpportunityID =opportunitiesList[0].Id,
                ClosedDate__c = date.Today(),
                Status = DO_Quote.QUOTE_STATUS_DRAFT,
                RecordTypeID=DO_Quote.QUOTE_CARDS_RECORDTYPE_ID
            )
            
        };
        
        List<Opportunity> newOpportunitiesList = (List<Opportunity>)fflib_ApexMocksUtils.makeRelationship(
            List<Opportunity>.class,
            opportunitiesList,
            Quote.OpportunityId,
            new List<List<Quote>> {objListQuote}
        );
        
        // Initialize framework        
        //Create Batch_Definition
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Batch_Name__c = 'BatchTest',
                Class_Name__c = 'Async_OpportunityNotClosedNotification',
                Job_Size__c = 200,
                SObject_API_Name__c = 'Opportunity'
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
                Name = 'daysInactiveOpportunity',
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

        mocks.startStubbing();
        mocks.when(opportunityRepository.getQuoteByOpportunityID((Set<Id>)fflib_match.anyObject())).thenReturn( newOpportunitiesList );
        mocks.when(opportunityRepository.getOpportunityByID((Set<Id>)fflib_match.anyObject())).thenReturn( opportunitiesList );
        ((ISL_ChatterNotifications) mocks.doAnswer( new VoidAnswer(),opportunityChatterNotification)).persistChatterPosts();
        mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
        mocks.when(jobExecutionRep.getJobExecutionByAsyncApexJobIdSet((Id)fflib_match.anyObject())).thenReturn(jobExecutionList);
        mocks.when(parameterRep.getParametersByParentId((Set<Id>)fflib_match.anyObject())).thenReturn(parametersList);
        mocks.stopStubbing();
        

        Async_OpportunityNotClosedNotification newBatchRun = new Async_OpportunityNotClosedNotification();
        newBatchRun =new Async_OpportunityNotClosedNotification(opportunityRepository, jobExecutionRep, parameterRep, opportunityChatterNotification);

        Database.executeBatch(newBatchRun);
        newBatchRun.setAsyncApexJobId(null);
        newBatchRun.execute(null, opportunitiesList);
        
        ((IREP_Opportunity)mocks.verify(opportunityRepository, 1)).getQuoteByOpportunityID((Set<Id>)fflib_match.anyObject());
        ((IREP_Opportunity)mocks.verify(opportunityRepository, 1)).getOpportunityByID((Set<Id>)fflib_match.anyObject());
        ((FW_IREP_JobExecution)mocks.verify(jobExecutionRep, 1)).getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject());
        ((FW_IREP_Parameters)mocks.verify(parameterRep, 1)).getParametersByParentId((Set<Id>)fflib_match.anyObject());
    }

    class VoidAnswer implements fflib_Answer {
        public Object answer (fflib_InvocationOnMock invocation) {
            return null;
        }
    }
}