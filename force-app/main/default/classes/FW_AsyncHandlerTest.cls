/** ​
    * @author           Jorge Antunes
    * @description      testClass for FW_AsyncHandler
    * ​
    * Modification Log ​
    *------------------------------------------------------------------------------------ ​
    * Developer                        Date                Description ​
    *------------------------------------------------------------------------------------ ​
    * Jorge Antunes                     23/09/2019          Initial version
*/
@isTest
public class FW_AsyncHandlerTest {
    // Initialize framework once
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    static void setAsyncApexJobIdRunWithDefaultTest(){
        // Create mocked repository object on the fly. 
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);

        // Initialize framework        
        //Create Batch_Definition
        list<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Batch_Name__c = 'batch test', 
                Class_Name__c = 'batch_test',
                Job_Size__c = 200, 
                SObject_API_Name__c = 'Account'
            )
        };
        //Create JobExecution
        list<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Run_With_Defaults__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
            )
        };

        //Create Parameters
        list<Parameters__c> parametersList = new List<Parameters__c>{
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = 'test',
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Value__c = 'value'
            )
        };

        //Mocking
        mocks.startStubbing();
            mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
            mocks.when(parameterRep.getParametersByParentId((Set<Id>)fflib_match.anyObject())).thenReturn(parametersList);
        mocks.stopStubbing();

        // Construct the service with the mocked implementation of the FW_AsyncHandler
        FW_AsyncHandler asyncHandler = new FW_AsyncHandler(jobExecutionRep,parameterRep, null);
        asyncHandler.setJobExecutionId(jobExecutionList.get(0).id);
        String asyncApexJobId = fflib_IDGenerator.generate(AsyncApexJob.sObjectType);
        asyncHandler.setAsyncApexJobId(asyncApexJobId);

        // Verify that calls to jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet with any id's set is equal to 1
        ((FW_IREP_JobExecution)mocks.verify(jobExecutionRep, 1)).getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject());
         // Verify that calls to parameterRep.getParametersByParentId with any id's set is equal to 1
        ((FW_IREP_Parameters)mocks.verify(parameterRep, 1)).getParametersByParentId((Set<Id>)fflib_match.anyObject());
    }

    @isTest
    static void setAsyncApexJobIdRunWithoutDefaultTest(){
        // Create mocked repository object on the fly. 
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);

        // Initialize framework        
        //Create Batch_Definition
        list<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Batch_Name__c = 'batch test', 
                Class_Name__c = 'batch_test',
                Job_Size__c = 200, 
                SObject_API_Name__c = 'Account'
            )
        };
        //Create JobExecution
        list<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Run_With_Defaults__c = false,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
            )
        };
        //Create Parameters
        list<Parameters__c> parametersList = new List<Parameters__c>{
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = 'test',
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Value__c = 'value'
            )
        };

        //Mocking
        mocks.startStubbing();
            mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
            mocks.when(parameterRep.getParametersByParentId((Set<Id>)fflib_match.anyObject())).thenReturn(parametersList);
        mocks.stopStubbing();

        // Construct the service with the mocked implementation of the FW_AsyncHandler
        FW_AsyncHandler asyncHandler = new FW_AsyncHandler(jobExecutionRep,parameterRep, null);
        asyncHandler.setJobExecutionId(jobExecutionList.get(0).id);
        String asyncApexJobId = fflib_IDGenerator.generate(AsyncApexJob.sObjectType);
        asyncHandler.setAsyncApexJobId(asyncApexJobId);
        
        // Verify that calls to jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet with any id's set is equal to 1
        ((FW_IREP_JobExecution)mocks.verify(jobExecutionRep, 1)).getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject());
         // Verify that calls to parameterRep.getParametersByParentId with any id's set is equal to 1
        ((FW_IREP_Parameters)mocks.verify(parameterRep, 1)).getParametersByParentId((Set<Id>)fflib_match.anyObject());
    }

    @isTest
    static void getParameterValueTest(){
        // Create mocked repository object on the fly. 
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);

        // Initialize framework        
        //Create Batch_Definition
        list<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Batch_Name__c = 'batch test', 
                Class_Name__c = 'batch_test',
                Job_Size__c = 200, 
                SObject_API_Name__c = 'Account'
            )
        };
        //Create JobExecution
        list<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Run_With_Defaults__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
            )
        };

        //Create Parameters
        list<Parameters__c> parametersList = new List<Parameters__c>{
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = 'test',
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Value__c = 'value'
            )
        };

        //Mocking
        mocks.startStubbing();
            mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
            mocks.when(parameterRep.getParametersByParentId((Set<Id>)fflib_match.anyObject())).thenReturn(parametersList);
        mocks.stopStubbing();

        // Construct the service with the mocked implementation of the FW_AsyncHandler
        FW_AsyncHandler asyncHandler = new FW_AsyncHandler(jobExecutionRep,parameterRep, null);
        asyncHandler.setJobExecutionId(jobExecutionList.get(0).id);
        String asyncApexJobId = fflib_IDGenerator.generate(AsyncApexJob.sObjectType);
        asyncHandler.setAsyncApexJobId(asyncApexJobId);

        //get parameters
        string parameter = asyncHandler.getParameterValue('test');
        //get invalid parameter
        string error = '';
        try{
           asyncHandler.getParameterValue('test2');
        } catch (FW_TriggerException ex){
            error = ex.getMessage();
        }

        // Verify that calls to jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet with any id's set is equal to 1
        ((FW_IREP_JobExecution)mocks.verify(jobExecutionRep, 1)).getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject());
         // Verify that calls to parameterRep.getParametersByParentId with any id's set is equal to 1
        ((FW_IREP_Parameters)mocks.verify(parameterRep, 1)).getParametersByParentId((Set<Id>)fflib_match.anyObject());

        //Asserts
        System.assertEquals('value', parameter);
        System.assertEquals(Label.Batch_Framework_Missing_Parameters_Exception, error);
    }

    @isTest
    static void startBatchTest(){
    // Create mocked repository object on the fly. 
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);

        // Initialize framework        
        //Create Batch_Definition
        list<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Batch_Name__c = 'batch test', 
                Class_Name__c = 'batch_test',
                Job_Size__c = 200, 
                SObject_API_Name__c = 'Account'
            )
        };
        //Create JobExecution
        list<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Run_With_Defaults__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
            )
        };

        //Create Parameters
        list<Parameters__c> parametersList = new List<Parameters__c>{
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = 'test',
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Value__c = 'value'
            )
        };

        //Mocking
        mocks.startStubbing();
            mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
            mocks.when(parameterRep.getParametersByParentId((Set<Id>)fflib_match.anyObject())).thenReturn(parametersList);
        mocks.stopStubbing();

        // Construct the service with the mocked implementation of the FW_AsyncHandler
        FW_AsyncHandler asyncHandler = new FW_AsyncHandler(jobExecutionRep,parameterRep, null);
        asyncHandler.setJobExecutionId(jobExecutionList.get(0).id);
        String asyncApexJobId = fflib_IDGenerator.generate(AsyncApexJob.sObjectType);
        asyncHandler.setAsyncApexJobId(asyncApexJobId);
        // Verify that calls to jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet with any id's set is equal to 1
        ((FW_IREP_JobExecution)mocks.verify(jobExecutionRep, 1)).getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject());
         // Verify that calls to parameterRep.getParametersByParentId with any id's set is equal to 1
        ((FW_IREP_Parameters)mocks.verify(parameterRep, 1)).getParametersByParentId((Set<Id>)fflib_match.anyObject());
        
        // Verify startBatch() methods changes correctly jobExecution values
        System.assertEquals(FW_DO_JobExecution.JOB_EXEC_STATUS_STARTED, jobExecutionList[0].Status__c);
        System.assertEquals(asyncApexJobId, jobExecutionList[0].AsyncApexJobId__c);
    }

    @isTest
    static void finishBatchWithoutExtendedStatusTest(){
        // Create mocked repository object on the fly. 
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_AsyncApexJob asyncApexJobRep = (FW_REP_AsyncApexJob)mocks.mock(FW_REP_AsyncApexJob.class);
        
        String asyncApexJobId = fflib_IDGenerator.generate(AsyncApexJob.sObjectType);

        // Initialize framework        
        //Create JobExecution
        list<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Run_With_Defaults__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW,
                AsyncApexJobId__c = asyncApexJobId
            )
        };
        //Create AsyncApexJob        
        String asyncApexObj = '[{"CompletedDate": "2020-01-01T00:00:00Z",'
                                +'"Id": "'+asyncApexJobId+'",'
                                +'"ParentJobId": "'+jobExecutionList.get(0).id+'",'
                                +'"Status": "",'
                                +'"ExtendedStatus": ""}]';
        list<AsyncApexJob> asyncApexList = (list<AsyncApexJob>)JSON.deserialize(asyncApexObj,List<AsyncApexJob>.class); 

        //Mocking
        mocks.startStubbing();
            mocks.when(jobExecutionRep.getJobExecutionByAsyncApexJobIdSet((Id)fflib_match.anyObject())).thenReturn(jobExecutionList);
            mocks.when(asyncApexJobRep.getAsyncApexJobListByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(asyncApexList);
        mocks.stopStubbing();

        // Construct the service with the mocked implementation of the FW_AsyncHandler
        FW_AsyncHandler asyncHandler = new FW_AsyncHandler();
        asyncHandler = new FW_AsyncHandler(jobExecutionRep,null, asyncApexJobRep);
        asyncHandler.setJobExecutionId(jobExecutionList.get(0).id);
        asyncHandler.finishBatch(asyncApexJobId);

        // Verify that calls to jobExecutionRep.getJobExecutionByAsyncApexJobIdSet with any id's set is equal to 1
        ((FW_IREP_JobExecution)mocks.verify(jobExecutionRep, 1)).getJobExecutionByAsyncApexJobIdSet((Id)fflib_match.anyObject());
         // Verify that calls to asyncApexJobRep.getAsyncApexJobListByIdSet with any id's set is equal to 1
        ((FW_IREP_AsyncApexJob)mocks.verify(asyncApexJobRep, 1)).getAsyncApexJobListByIdSet((Set<Id>)fflib_match.anyObject());
        System.assertEquals(FW_DO_JobExecution.JOB_EXEC_STATUS_FINISHED, jobExecutionList[0].Status__c);
    }

    @isTest
    static void finishBatchWithExtendedStatusTest(){
        // Create mocked repository object on the fly. 
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_AsyncApexJob asyncApexJobRep = (FW_REP_AsyncApexJob)mocks.mock(FW_REP_AsyncApexJob.class);
        
        String asyncApexJobId = fflib_IDGenerator.generate(AsyncApexJob.sObjectType);

        // Initialize framework        
        //Create JobExecution
        list<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Run_With_Defaults__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW,
                AsyncApexJobId__c = asyncApexJobId
            )
        };
        //Create AsyncApexJob        
        String asyncApexObj = '[{"CompletedDate": "2020-01-01T00:00:00Z",'
                                +'"Id": "'+asyncApexJobId+'",'
                                +'"ParentJobId": "'+jobExecutionList.get(0).id+'",'
                                +'"Status": "",'
                                +'"ExtendedStatus": "test"}]';
        list<AsyncApexJob> asyncApexList = (list<AsyncApexJob>)JSON.deserialize(asyncApexObj,List<AsyncApexJob>.class); 

        //Mocking
        mocks.startStubbing();
            mocks.when(jobExecutionRep.getJobExecutionByAsyncApexJobIdSet((Id)fflib_match.anyObject())).thenReturn(jobExecutionList);
            mocks.when(asyncApexJobRep.getAsyncApexJobListByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(asyncApexList);
        mocks.stopStubbing();

        // Construct the service with the mocked implementation of the FW_AsyncHandler
        FW_AsyncHandler asyncHandler = new FW_AsyncHandler();
        asyncHandler = new FW_AsyncHandler(jobExecutionRep,null, asyncApexJobRep);
        asyncHandler.setJobExecutionId(jobExecutionList.get(0).id);
        asyncHandler.finishBatch(asyncApexJobId);

        // Verify that calls to jobExecutionRep.getJobExecutionByAsyncApexJobIdSet with any id's set is equal to 1
        ((FW_IREP_JobExecution)mocks.verify(jobExecutionRep, 1)).getJobExecutionByAsyncApexJobIdSet((Id)fflib_match.anyObject());
         // Verify that calls to asyncApexJobRep.getAsyncApexJobListByIdSet with any id's set is equal to 1
        ((FW_IREP_AsyncApexJob)mocks.verify(asyncApexJobRep, 1)).getAsyncApexJobListByIdSet((Set<Id>)fflib_match.anyObject());
        System.assertEquals(FW_DO_JobExecution.JOB_EXEC_STATUS_FINISHED_ERRORS, jobExecutionList[0].Status__c);
    }

    @isTest
    static void executeQueryTest(){
        // Create mocked repository object on the fly. 
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);

        // Initialize framework        
        //Create Batch_Definition
        list<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Batch_Name__c = 'batch test', 
                Class_Name__c = 'batch_test',
                Job_Size__c = 200, 
                SObject_API_Name__c = 'Account'
            )
        };
        //Create JobExecution
        list<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Run_With_Defaults__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
            )
        };
        //Create Parameters
        list<Parameters__c> parametersList = new List<Parameters__c>{
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = 'IdList',
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Value__c = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType)+','+fflib_IDGenerator.generate(Batch_Definition__c.sObjectType)
            )
        };

        //Mocking
        mocks.startStubbing();
            mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
            mocks.when(parameterRep.getParametersByParentId((Set<Id>)fflib_match.anyObject())).thenReturn(parametersList);
        mocks.stopStubbing();

        // Construct the service with the mocked implementation of the FW_AsyncHandler
        FW_AsyncHandler asyncHandler = new FW_AsyncHandler(jobExecutionRep,parameterRep, null);
        asyncHandler.setJobExecutionId(jobExecutionList.get(0).id);
        String asyncApexJobId = fflib_IDGenerator.generate(AsyncApexJob.sObjectType);
        asyncHandler.setAsyncApexJobId(asyncApexJobId);

        FW_QueryBuilder query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
                    .selectFields(FW_REP_JobExecution.JOBEXECUTION_FIELDS);
        Database.QueryLocator queryLocator = asyncHandler.executeQuery(query);

        FW_QueryBuilder query1 = new FW_QueryBuilder(Job_Execution__c.SObjectType)
                    .selectFields(FW_REP_JobExecution.JOBEXECUTION_FIELDS)
                    .whereIn('Id', (list<Object>)asyncHandler.getParameterValue('IdList').split(','));

        //Asserts
        System.assertEquals(string.valueOf(Database.getQueryLocator(query1.getQuery())), String.valueOf(queryLocator));
    }
}