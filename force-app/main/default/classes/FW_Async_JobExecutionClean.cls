/**
    * @description   Batch class to have Job Excution records deleted if the diference between the created date and the
                    current date is equal or greater than the value defined on the parameter
    * @testClass     FW_Async_JobExecutionCleanTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
global class FW_Async_JobExecutionClean extends FW_AsyncHandler implements Database.Batchable<sObject>, Database.stateful {
    
    private static final String DAYS = 'Days';
    private static final String STATUS = 'Status';

    global FW_Async_JobExecutionClean(){
        
    }
    
    @testVisible
    private FW_Async_JobExecutionClean(FW_IREP_JobExecution jobExecutionRep, FW_IREP_Parameters parameterRep){
        this.jobExecutionRep = jobExecutionRep;
        this.parameterRep = parameterRep;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        setAsyncApexJobId(bc.getJobId());
                
        Integer days = Integer.valueOf(getParameterValue(DAYS));
        List<String> statusList = getParameterValue(STATUS).split(',');
        String dateStart= String.valueOf(DATE.TODAY().addDays(days)) + 'T00:00:00.000+0000';
        
        FW_QueryBuilder query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectFields(FW_REP_JobExecution.JOBEXECUTION_FIELDS)
            .setWhere('CreatedDate <= ' + dateStart)
            .whereIn('Status__c', statusList);
        
        return executeQuery(query);
    }

    global void execute(Database.BatchableContext bc, List<Job_Execution__c> jobExecutionList) {
        if(!jobExecutionList.isEmpty()){
            jobExecutionRep.deleteSObjects(jobExecutionList);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        finishBatch(bc.getJobId());
    }
}