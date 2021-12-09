@isTest
private class FW_TW_BatchDefinition_DefaultParamTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void jobExecutionDefaultParamTest(){
        FW_IREP_Parameters parametersRepository = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);
        
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>();
        batchDefinitionList.add(
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType)
            )  
        );

        List<Parameters__c> parameterList = new List<Parameters__c>();
        parameterList.add(
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).Id
            ) 
        );

        mocks.startStubbing();
            mocks.when(parametersRepository.insertSObjects(parameterList)).thenReturn(new List<Database.SaveResult>());
        mocks.stopStubbing();
       
        FW_TW_BatchDefinition_DefaultParam jobExecutionWorker = new FW_TW_BatchDefinition_DefaultParam();
        jobExecutionWorker = new FW_TW_BatchDefinition_DefaultParam(parametersRepository);
        
        jobExecutionWorker.execute(batchDefinitionList);
        
        ((FW_IREP_Parameters)mocks.verify(parametersRepository, 1)).insertSObjects((List<Parameters__c>)fflib_match.anyList());
    }
}