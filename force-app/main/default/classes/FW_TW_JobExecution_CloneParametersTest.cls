@isTest
private class FW_TW_JobExecution_CloneParametersTest {
 	static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    private static void jobExecutionCloneParametersTest(){
        FW_IREP_Parameters parametersRepository = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);
        FW_IDO_JobExecution jobExecutionDomain = (FW_DO_JobExecution)mocks.mock(FW_DO_JobExecution.class);
        
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>();
        batchDefinitionList.add(
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType)
            )  
        );
        
        List<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>();
        jobExecutionList.add(
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW,
                Run_with_Defaults__c = false
                
            )
        );
        
        jobExecutionList.add(
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW,
                Run_with_Defaults__c = true
                
            )
        );

        jobExecutionList.add(
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).Id,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW,
                Run_with_Defaults__c = false
                
            )
        );
        
        List<Parameters__c> parameterList = new List<Parameters__c>();
        parameterList.add(
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).Id
            ) 
        );

        List<Parameters__c> parameterListCloned = new List<Parameters__c>();
        parameterListCloned.add(
            new Parameters__c(
                Job_Execution__c = jobExecutionList.get(0).Id
            ) 
        );
        parameterListCloned.add(
            new Parameters__c(
                Job_Execution__c = jobExecutionList.get(2).Id
            ) 
        );

        mocks.startStubbing();
            mocks.when(jobExecutionDomain.isRunningwithDefaults((Job_Execution__c)jobExecutionList.get(0))).thenReturn(false);
            mocks.when(jobExecutionDomain.isRunningwithDefaults((Job_Execution__c)jobExecutionList.get(1))).thenReturn(true);
            mocks.when(jobExecutionDomain.isRunningwithDefaults((Job_Execution__c)jobExecutionList.get(2))).thenReturn(false);
            mocks.when(parametersRepository.getParametersByBatchDefinitionId(new Set<Id>{batchDefinitionList.get(0).Id})).thenReturn(parameterList);
            mocks.when(jobExecutionDomain.getClonedParameter(parameterList.get(0),jobExecutionList.get(0).Id)).thenReturn(parameterListCloned.get(0));
            mocks.when(jobExecutionDomain.getClonedParameter(parameterList.get(0),jobExecutionList.get(2).Id)).thenReturn(parameterListCloned.get(1));
            mocks.when(parametersRepository.insertSObjects(parameterListCloned)).thenReturn(new List<Database.SaveResult>());
        mocks.stopStubbing();
        
        FW_TW_JobExecution_CloneParameters jobExecutionWorker = new FW_TW_JobExecution_CloneParameters();
        jobExecutionWorker = new FW_TW_JobExecution_CloneParameters(parametersRepository, jobExecutionDomain);
        
        jobExecutionWorker.execute(jobExecutionList);
        
        ((FW_IDO_JobExecution)mocks.verify(jobExecutionDomain, 3)).isRunningwithDefaults((Job_Execution__c)fflib_match.anySObject());
        ((FW_IREP_Parameters)mocks.verify(parametersRepository, 1)).getParametersByBatchDefinitionId(new Set<Id>{batchDefinitionList.get(0).Id});
        ((FW_IREP_Parameters)mocks.verify(parametersRepository, 1)).insertSObjects(parameterListCloned);
    }
}