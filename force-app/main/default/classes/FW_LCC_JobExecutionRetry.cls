/**
    * @description   Lightning component controller for Job Execution component
    * @testClass     FW_LCC_JobExecutionRetryTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public without sharing class FW_LCC_JobExecutionRetry {
    private static FW_REP_ErrorLog errorLogRepository = new FW_REP_ErrorLog();
    private static FW_REP_JobExecution jobExecutionRepository = new FW_REP_JobExecution();
    private static FW_REP_Parameters parameterRepository = new FW_REP_Parameters();
    private static FW_DO_JobExecution jobExecutionDomain = new FW_DO_JobExecution();
    
    /**
        *  @description:    Method to retrieve errors related to a job execution
    */
    @AuraEnabled
    public static List<Error_Log__c> getErrorList(Id jobExecutionId){
        return errorLogRepository.getErrorLogListByJobExecutionIdSet(new Set<Id>{jobExecutionId});
    }
    
    /**
        *  @description:    Create job Execution from an error log
    */
    @AuraEnabled
    public static void createJobExecutions(List<Id> errorListId){

        List<Error_Log__c> errorList = errorLogRepository.getErrorLogListByIdSet(new Set<Id>(errorListId));
        
        Id initialJobRTId = Schema.SObjectType.Job_Execution__c.getRecordTypeInfosByDeveloperName().get(FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_INITIAL).getRecordTypeId();
        Map<Id, Job_Execution__c> jobExecutionByErrorIdMap = new Map<Id, Job_Execution__c>();
        for(Error_Log__c error : errorList){
            Integer jobSize = 200;
            if(!String.isEmpty(error.Job_Scope__c)){
                jobSize = error.Job_Scope__c.split(',').size();
            }
            
            Job_Execution__c newJob = new Job_Execution__c(Job_Execution__c = error.Job_Execution__c,
                                                                   Batch_Definition__c = error.Job_Execution__r.Batch_Definition__c,
                                                                   RecordTypeId = initialJobRTId,
                                                                   Run_with_Defaults__c = false,
                                                                   Job_Size__c = jobSize
                                                                   ); 
            jobExecutionByErrorIdMap.put(error.id, newJob);    
        }
        
        //jobExecutionRepository.insertSObjects(jobExecutionByErrorIdMap.values());
        insert jobExecutionByErrorIdMap.values();
        List<Parameters__c> parentParameterList;
        if(errorList.get(0).Job_Execution__r.Run_with_Defaults__c){
            parentParameterList = parameterRepository.getParametersByParentId(new Set<Id>{errorList.get(0).Job_Execution__r.Batch_Definition__c}); 
        }else{
            parentParameterList = parameterRepository.getParametersByParentId(new Set<Id>{errorList.get(0).Job_Execution__c});
        }
        
        List<Parameters__c> parameterList = new List<Parameters__c>();
        for(Error_Log__c error : errorList){
            parameterList.add(new Parameters__c(Description__c = Label.Job_Execution_Default_Parameter_Comment,
                                                    Job_Execution__c = jobExecutionByErrorIdMap.get(error.Id).Id,
                                                    Value__c = error.Job_Scope__c,
                                                    Name = FW_AsyncHandler.DEFAULT_PARAMETER));
            
            for(Parameters__c parameter : parentParameterList){
                if(parameter.Name != FW_AsyncHandler.DEFAULT_PARAMETER){
                    parameterList.add(jobExecutionDomain.getClonedParameter(parameter, jobExecutionByErrorIdMap.get(error.Id).Id));
                }
            }
                                                    
        }
        parameterRepository.insertSObjects(parameterList);
        errorLogRepository.updateSObjects(errorList);
    }
}