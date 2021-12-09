/**
    * @description    worker class to log all error catched from the Batchs
    * @testClass      FW_TW_BatchApexErrorEventLogTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public class FW_TW_BatchApexErrorEventLog {
    
    private FW_IREP_AsyncApexJob asyncApexJobRepository;
    private FW_IREP_JobExecution jobExecutionRepository;
    private FW_ISL_ErrorHandling errorHandler;
    
    public FW_TW_BatchApexErrorEventLog() {
        this(new FW_REP_AsyncApexJob(), new FW_REP_JobExecution(), new FW_SL_ErrorHandling());
    }
    
    @TestVisible
    private FW_TW_BatchApexErrorEventLog(FW_IREP_AsyncApexJob asyncApexJobRepository, FW_IREP_JobExecution jobExecutionRepository, FW_ISL_ErrorHandling errorHandler) {
        this.asyncApexJobRepository = asyncApexJobRepository;
        this.jobExecutionRepository = jobExecutionRepository;
        this.errorHandler = errorHandler;
    }
    
    public void execute(List<BatchApexErrorEvent> batchEventList) {
        
        Set<Id> jobIdSet = new Set<Id>();
        for (BatchApexErrorEvent event : batchEventList) {
            jobIdSet.add(event.AsyncApexJobId);            
        }

        Map<Id, AsyncApexJob> jobMap = new Map<Id, AsyncApexJob>(asyncApexJobRepository.getAsyncApexJobListByIdSet(jobIdSet));
        Set<Id> parentJobIdSet = new Set<Id>();
        for(AsyncApexJob asyncJob : jobMap.values()){
            parentJobIdSet.add(asyncJob.ParentJobId);
        }
        
        Map<Id, Id> jobExecutionByJobIdMap = new Map<Id, Id>();

        List<Job_Execution__c> jobExecutions = jobExecutionRepository.getJobExecutionByAsyncApexJobIdSet(parentJobIdSet);
        for(Job_Execution__c job : jobExecutions) {
            jobExecutionByJobIdMap.put(job.AsyncApexJobId__c, job.Id);
        }
      
        for(BatchApexErrorEvent event : batchEventList) {
            if(jobMap.get(event.AsyncApexJobId) != null){
                errorHandler.writeLog(event, jobExecutionByJobIdMap.get(jobMap.get(event.AsyncApexJobId).ParentJobId));
            }
        }

        errorHandler.saveLogs();
    }
}