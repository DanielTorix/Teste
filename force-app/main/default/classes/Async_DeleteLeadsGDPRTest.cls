/**
@author Guilherme Charro
@date    07/10/2021
@description Test class for Async_DeleteLeadsGDPR
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                   07/10/2021         Original Version                       100
*/
@isTest
private class Async_DeleteLeadsGDPRTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    static void DeleteLeadsGDPRTest() {
        IREP_Lead leadRepository = (REP_Lead)mocks.mock(REP_Lead.class);
        ISL_ChatterNotifications contactChatterNotification = (SL_ChatterNotifications)mocks.mock(SL_ChatterNotifications.class);
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);
            
        //Create Batch_Definition
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Batch_Name__c = 'BatchTest',
                Class_Name__c = 'Async_DeleteLeadsGDPR',
                Job_Size__c = 200,
                SObject_API_Name__c = 'Lead'
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
            
        List<Lead> leadList = new List<Lead>{
            new Lead(
                Id = fflib_IDGenerator.generate(Lead.sObjectType),
                GeneralGDPR__c = DO_Lead.LEAD_GDPR_NO
            )
        };

        mocks.startStubbing();
        mocks.when(leadRepository.deleteSObjects((List<Contact>)fflib_match.anyList())).thenReturn(new List<Database.DeleteResult>());
        mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
        mocks.when(jobExecutionRep.getJobExecutionByAsyncApexJobIdSet((Id)fflib_match.anyObject())).thenReturn(jobExecutionList);
        mocks.when(parameterRep.getParametersByParentId((Set<Id>)fflib_match.anyObject())).thenReturn(parametersList);
        mocks.stopStubbing();
           
 
        Async_DeleteLeadsGDPR newBatchRun = new Async_DeleteLeadsGDPR();
        newBatchRun =new Async_DeleteLeadsGDPR(leadRepository, jobExecutionRep, parameterRep);

        Database.executeBatch(newBatchRun);
        newBatchRun.setAsyncApexJobId(null);
        newBatchRun.execute(null, leadList);
        
        ((FW_IREP_JobExecution)mocks.verify(jobExecutionRep, 1)).getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject());
        ((FW_IREP_Parameters)mocks.verify(parameterRep, 1)).getParametersByParentId((Set<Id>)fflib_match.anyObject());
        ((IREP_Lead)mocks.verify(leadRepository, 1)).deleteSObjects((List<Lead>) fflib_match.anyList());
    }
}