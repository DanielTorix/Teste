@isTest
private class FW_TW_JobExecution_ValidationsTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    private static void jobExecutionValidationsTest(){
        
        FW_IREP_BatchDefinition batchDefinitionRepository = (FW_REP_BatchDefinition)mocks.mock(FW_REP_BatchDefinition.class);
        
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>();
        batchDefinitionList.add(
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType)
            )  
        );
        batchDefinitionList.add(
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType)
            )  
        );

        List<Job_Execution__c> jobExecutionNewList = new List<Job_Execution__c>();
        Map<id,Job_Execution__c> jobExecutionOldMap = new Map<id,Job_Execution__c>();
        
        Id Id1 = fflib_IDGenerator.generate(Job_Execution__c.sObjectType);
        jobExecutionNewList.add(
            new Job_Execution__c(
                Id = Id1,
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
                
            )
        );
        jobExecutionOldMap.put(Id1,
            new Job_Execution__c(
                Id = Id1,
                Batch_Definition__c = batchDefinitionList.get(1).Id,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
                
            )
        );

        Id Id2 = fflib_IDGenerator.generate(Job_Execution__c.sObjectType);
        jobExecutionNewList.add(
            new Job_Execution__c(
                Id = Id2,
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Run_with_Defaults__c = true,
                Job_Size__c = 2,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
                
            )
        );
        jobExecutionOldMap.put(Id2,
            new Job_Execution__c(
                Id = Id2,
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Run_with_Defaults__c = true,
                Job_Size__c = 3,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
                
            )
        );    

        Id Id3 = fflib_IDGenerator.generate(Job_Execution__c.sObjectType);
        jobExecutionNewList.add(
            new Job_Execution__c(
                Id = Id3,
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Run_with_Defaults__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_STARTED
                
            )
        );
        jobExecutionOldMap.put(Id3,
            new Job_Execution__c(
                Id = Id3,
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Run_with_Defaults__c = false,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_STARTED
                
            )
        );
        
        Id Id4 = fflib_IDGenerator.generate(Job_Execution__c.sObjectType);
        jobExecutionNewList.add(
            new Job_Execution__c(
                Id = Id4,
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Run_with_Defaults__c = true,
                Execute__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
                
            )
        );
        jobExecutionOldMap.put(Id4,
            new Job_Execution__c(
                Id = Id4,
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Run_with_Defaults__c = false,
                Execute__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
                
            )
        );

        Id Id5 = fflib_IDGenerator.generate(Job_Execution__c.sObjectType);
        jobExecutionNewList.add(
            new Job_Execution__c(
                Id = Id5,
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Execute__c = false,
                Queried_Records__c = 1,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
                
            )
        );
        jobExecutionOldMap.put(Id5,
            new Job_Execution__c(
                Id = Id5,
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Execute__c = false,
                Queried_Records__c = 2,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
                
            )
        );

        Id Id6 = fflib_IDGenerator.generate(Job_Execution__c.sObjectType);
        jobExecutionNewList.add(
            new Job_Execution__c(
                Id = Id6,
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Execute__c = true,
                Queried_Records__c = 1,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_STARTED
                
            )
        );
        jobExecutionOldMap.put(Id6,
            new Job_Execution__c(
                Id = Id6,
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Execute__c = true,
                Queried_Records__c = 1,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_STARTED
                
            )
        );

        mocks.startStubbing();            
            mocks.when(batchDefinitionRepository.getBatchDefinitionByIdSet(new Set<Id>{batchDefinitionList.get(0).Id})).thenReturn(batchDefinitionList);
        mocks.stopStubbing();
        
        FW_TW_JobExecution_Validations jobExecutionWorker = new FW_TW_JobExecution_Validations(batchDefinitionRepository);
                
        jobExecutionWorker.execute(jobExecutionNewList,jobExecutionOldMap);      

        ((FW_IREP_BatchDefinition)mocks.verify(batchDefinitionRepository, 1)).getBatchDefinitionByIdSet((Set<Id>)fflib_match.eq(new Set<Id>{batchDefinitionList.get(0).Id}));

        Set<String> errorsLabelSet = new Set<String>{
            Label.Batch_Framework_Execution_Status_Validation,
            Label.Batch_Framework_Date_Time_Validation,
            Label.Batch_Framework_Default_Run_Changed_Validation,
            Label.Batch_Framework_Job_Size_Changed_Validation,
            Label.Batch_Framework_Batch_Definition_Changed
        };

        for( ApexPages.Message errorThrown : ApexPages.getMessages() ){
            system.assert( errorsLabelSet.contains( errorThrown.getDetail() ) );
        }
    }
}