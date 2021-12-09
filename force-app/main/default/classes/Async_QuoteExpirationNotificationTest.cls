@isTest
public class Async_QuoteExpirationNotificationTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    @isTest
    static void Async_QuoteExpirationDateNotificationExecute() {
        IREP_Quote quoteRepository = (REP_Quote)mocks.mock(REP_Quote.class);
        ISL_ChatterNotifications quoteChatterNotification = (SL_ChatterNotifications)mocks.mock(SL_ChatterNotifications.class);
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);

        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Quote> quotesList = FW_TestDataFactory.createQuote(1, true);
            
            
            // Initialize framework        
            //Create Batch_Definition
            List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
                new Batch_Definition__c(
                    Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                    Batch_Name__c = 'BatchTest',
                    Class_Name__c = 'Async_QuoteExpirationDateNotification',
                    Job_Size__c = 200,
                    SObject_API_Name__c = 'Quote'
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
                    Name = 'daysBeforeCloseQuote',
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
            mocks.when(quoteRepository.getQuoteByID((Set<Id>)fflib_match.anyObject())).thenReturn( quotesList );
            ((ISL_ChatterNotifications) mocks.doAnswer( new VoidAnswer(),quoteChatterNotification)).persistChatterPosts();
            mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
            mocks.when(jobExecutionRep.getJobExecutionByAsyncApexJobIdSet((Id)fflib_match.anyObject())).thenReturn(jobExecutionList);
            mocks.when(parameterRep.getParametersByParentId((Set<Id>)fflib_match.anyObject())).thenReturn(parametersList);
            mocks.stopStubbing();
           
 
            Async_QuoteExpirationDateNotification newBatchRun = new Async_QuoteExpirationDateNotification();
            newBatchRun =new Async_QuoteExpirationDateNotification(quoteRepository, jobExecutionRep, parameterRep, quoteChatterNotification);

            Database.executeBatch(newBatchRun);
            newBatchRun.setAsyncApexJobId(null);
            newBatchRun.execute(null, quotesList);
            
        }
    }
    class VoidAnswer implements fflib_Answer {
        public Object answer (fflib_InvocationOnMock invocation) {
            return null;
        }
    }
}