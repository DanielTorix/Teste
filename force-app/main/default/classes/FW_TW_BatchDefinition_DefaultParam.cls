/**
    * @description   Worker class to create default parameters on batch definitions
    * @testClass     FW_TW_BatchDefinition_DefaultParamTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------  
**/
public without sharing class FW_TW_BatchDefinition_DefaultParam  {
    
    private FW_IREP_Parameters parameterRepository;
    
    public FW_TW_BatchDefinition_DefaultParam(){
        this.parameterRepository = new FW_REP_Parameters();
    }
    
    @TestVisible
    private FW_TW_BatchDefinition_DefaultParam(FW_IREP_Parameters parameterRepository){
        this.parameterRepository = parameterRepository;
    }

    public void execute(list<Batch_Definition__c> newBDList) {
        List<Parameters__c> defaultParametersList = new List<Parameters__c>();

        for(Batch_Definition__c batchDefinition: newBDList) {
            defaultParametersList.add(
                new Parameters__c(
                    Name=FW_AsyncHandler.DEFAULT_PARAMETER, 
                    Description__c=Label.Job_Execution_Default_Parameter_Comment,
                    Batch_Definition__c=batchDefinition.Id
                )
            );
        }

        if(!defaultParametersList.isEmpty()){
            parameterRepository.insertSObjects(defaultParametersList);
        }
    }
}