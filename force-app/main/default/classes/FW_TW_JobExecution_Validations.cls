/**  
	* @description  Worker class to manage Job executions validations
	* @testClass    FW_THWB_JobExecution_ValidationsTes
	* Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------  
**/
public class FW_TW_JobExecution_Validations {
    
    private FW_IREP_BatchDefinition batchDefinitionRepository;
    
    public FW_TW_JobExecution_Validations(){
        this.batchDefinitionRepository = new FW_REP_BatchDefinition();
    }
     
    @TestVisible
    private FW_TW_JobExecution_Validations(FW_IREP_BatchDefinition batchDefinitionRepository){
        this.batchDefinitionRepository = batchDefinitionRepository;
    }

    public void execute(List<Job_Execution__c> newJobExecList, Map<id,Job_Execution__c> oldJobExecMap) {
        
        Set<Id> batchDefinitionIdSet = new Set<Id>();
        for(Job_Execution__c jobExecution: newJobExecList) {
            batchDefinitionIdSet.add(jobExecution.Batch_Definition__c);
        }

        Map<Id, Batch_Definition__c> batchDefinitionMap = new Map<Id, Batch_Definition__c>(batchDefinitionRepository.getBatchDefinitionByIdSet(batchDefinitionIdSet));
        
        for(Job_Execution__c jobExecution: newJobExecList) {
            if(jobExecution.Status__c != FW_DO_JobExecution.JOB_EXEC_STATUS_CANCELLED && oldJobExecMap.containsKey(jobExecution.Id)){
                validateLocalExecution(jobExecution, oldJobExecMap.get(jobExecution.Id));
            }
        }
    }
   
    
    /**
        *  @description:    Checks filled fields to execute job from Salesforce and validate fields changes
    **/ 
    private void validateLocalExecution(Job_Execution__c newJobExecution, Job_Execution__c oldJobExecution){
        if(newJobExecution.Execute__c){    
            if(newJobExecution.Status__c != FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
                && !(newJobExecution.Batch_Finish__c != oldJobExecution.Batch_Finish__c
                || newJobExecution.Batch_Start__c != oldJobExecution.Batch_Start__c
                || newJobExecution.Queried_Records__c != oldJobExecution.Queried_Records__c)){
                newJobExecution.addError(Label.Batch_Framework_Execution_Status_Validation);

            }else if(newJobExecution.Scheduled_Execution_DateTime__c == null){
                newJobExecution.Scheduled_Execution_DateTime__c.addError(Label.Batch_Framework_Date_Time_Validation);
            }
        } else if (newJobExecution.Run_with_Defaults__c != oldJobExecution.Run_with_Defaults__c) {
            newJobExecution.addError(Label.Batch_Framework_Default_Run_Changed_Validation);
        } else if (newJobExecution.Job_Size__c != oldJobExecution.Job_Size__c
                && newJobExecution.Run_with_Defaults__c) {
            newJobExecution.addError(Label.Batch_Framework_Job_Size_Changed_Validation);                    

        } else if (newJobExecution.Batch_Definition__c != oldJobExecution.Batch_Definition__c) {
            newJobExecution.addError(Label.Batch_Framework_Batch_Definition_Changed);
        }
    }
}