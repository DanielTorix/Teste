/**
    @description    worker class to copy default configuration from Batch Definition to JobExecution when it is set to run with defaults
    @testClass      FW_THWB_JobExecution_CopyBDConfigTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------
*/
public without sharing class FW_TW_JobExecution_CopyBDConfig {
    private FW_IREP_BatchDefinition bdRepository;
    
    public FW_TW_JobExecution_CopyBDConfig(){
        this.bdRepository = new FW_REP_BatchDefinition();
    }
    
    @TestVisible
    private FW_TW_JobExecution_CopyBDConfig(FW_IREP_BatchDefinition bdRepository){
        this.bdRepository = bdRepository;
    }

    public void execute(List<Job_Execution__c> jobExecList) {
        Set<Id> batchDefinitionIdSet = new Set<Id>();
        for(Job_Execution__c je : jobExecList){
            if(je.Run_with_Defaults__c){
                batchDefinitionIdSet.add(je.Batch_Definition__c);
            }
        }
        
        if(!batchDefinitionIdSet.isEmpty()){
            Map<Id,Batch_Definition__c> parametersMap = New Map<id, Batch_Definition__c>(bdRepository.getBatchDefinitionByIdSet(batchDefinitionIdSet));
            for(Job_Execution__c je : jobExecList){
                je.Job_Size__c = parametersMap.get(je.Batch_Definition__c).Job_Size__c;
            }
        }
    }
}