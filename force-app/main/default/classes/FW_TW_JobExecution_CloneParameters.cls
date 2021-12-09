/**
    @description    worker class to copy default parameter to the job execution record
    @testClass      FW_TW_JobExecution_CloneParametersTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------        
*/

public without sharing class FW_TW_JobExecution_CloneParameters {

    private FW_IREP_Parameters parametersRepository;
    private FW_IDO_JobExecution jobExecutionDomain;
    
    public FW_TW_JobExecution_CloneParameters(){
        this.parametersRepository = new FW_REP_Parameters();
        this.jobExecutionDomain = new FW_DO_JobExecution();
    }
    
    @TestVisible
    private FW_TW_JobExecution_CloneParameters(FW_IREP_Parameters parametersRepository, FW_IDO_JobExecution jobExecutionDomain){
        this.parametersRepository = parametersRepository;
        this.jobExecutionDomain = jobExecutionDomain;
    }

    public void execute(List<Job_Execution__c> jobExecutionList) {
        
        Map<Id, List<Job_Execution__c>> jobExecutionIdByBatchDefinitionIdMap = new Map<Id, List<Job_Execution__c>>();
        for(Job_Execution__c je : jobExecutionList){
            if(!jobExecutionDomain.isRunningwithDefaults(je) && !isChildJob(je)){
                if(jobExecutionIdByBatchDefinitionIdMap.get(je.Batch_Definition__c) == null){
                    jobExecutionIdByBatchDefinitionIdMap.put(je.Batch_Definition__c, new List<Job_Execution__c>{je});
                }else{
                    jobExecutionIdByBatchDefinitionIdMap.get(je.Batch_Definition__c).add(je);
                }
            } 
        }
        
        if(!jobExecutionIdByBatchDefinitionIdMap.keyset().isEmpty()){
            List<Parameters__c> parameters = parametersRepository.getParametersByBatchDefinitionId(jobExecutionIdByBatchDefinitionIdMap.keyset());
            
            List<Parameters__c> newParameters = new List<Parameters__c>();
            for(Parameters__c parameter : parameters){
                for(Job_Execution__c jobExecution : jobExecutionIdByBatchDefinitionIdMap.get(parameter.Batch_Definition__c)){
                    if(jobExecution.Job_Execution__c == null || jobExecution.Job_Execution__c == ''){
                        newParameters.add(jobExecutionDomain.getClonedParameter(parameter, jobExecution.Id));
                    }
                }
            }
            parametersRepository.insertSObjects(newParameters);  
        }
        
    }

    /**
        * @description:         Validates if Job Execution is null
    */
    private boolean isChildJob(Job_Execution__c je){
        return je.Job_Execution__c != null;
    }
}