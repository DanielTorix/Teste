/**
    * @description   Handler class for batch framework
    * @testClass     FW_AsyncHandlerTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public virtual class FW_AsyncHandler implements Database.RaisesPlatformEvents, FW_IAsync{

    public final static String DEFAULT_PARAMETER = 'IdList';

    private Job_Execution__c jobExecution;
    private Id asyncApexJobId;
    private Id jobExecutionId;
    private Map<String, Parameters__c> parametersMap; 
    protected FW_IREP_JobExecution jobExecutionRep;
    protected FW_IREP_Parameters parameterRep;
    protected FW_IREP_AsyncApexJob asyncApexJobRep;

    public FW_AsyncHandler(){
        jobExecutionRep = new FW_REP_JobExecution();
        parameterRep = new FW_REP_Parameters();
        asyncApexJobRep = new FW_REP_AsyncApexJob();
    }

    @testVisible
    private FW_AsyncHandler(FW_IREP_JobExecution jobExecutionRep, FW_IREP_Parameters parameterRep, FW_IREP_AsyncApexJob asyncApexJobRep) {
        this.jobExecutionRep = jobExecutionRep;
        this.parameterRep = parameterRep;
        this.asyncApexJobRep = asyncApexJobRep;
    }

    public void setJobExecutionId(Id jobExecutionId){
        this.jobExecutionId = jobExecutionId;
    }

    /**
        *  @description:    get the job Id and the parameters and start the batch
    */
    public void setAsyncApexJobId(Id asyncApexJobId){
        
        this.asyncApexJobId = asyncApexJobId;
        Set<Id> parentIdSet = new Set<Id>();
        list<Job_Execution__c> jobExecutionList = jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet(new Set<id>{this.jobExecutionId});
        this.jobExecution = jobExecutionList.get(0);
        
        if (this.jobExecution.Run_With_Defaults__c) {
            parentIdSet.add(this.jobExecution.Batch_Definition__c);
        } else {
            parentIdSet.add(this.jobExecution.id);
        }
        
        parametersMap = new Map<String, Parameters__c>();
        if (!parentIdSet.isEmpty()) {
            for (Parameters__c parameter : parameterRep.getParametersByParentId(parentIdSet)){
                parametersMap.put(parameter.name, parameter);
            }
        }
        startBatch();
    }

    /**
        *  @description:    Get the parameter value
    */
    public String getParameterValue(String parameterName){
        if (parametersMap.containsKey(parameterName)) {
            return parametersMap.get(parameterName).Value__c;
        } 
        throw new FW_TriggerException(Label.Batch_Framework_Missing_Parameters_Exception);
    }

    /**
        *  @description:    
    */
    public void startBatch(){
        jobExecution.Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_STARTED;
        jobExecution.Batch_Start__c = System.now();
        jobExecution.AsyncApexJobId__c = AsyncApexJobId; 
        jobExecutionRep.updateSObjects(new List<Job_Execution__c>{jobExecution});
    }

    /**
        *  @description:    
    */
    public void finishBatch(Id asyncApexJobId){
        jobExecution = jobExecutionRep.getJobExecutionByAsyncApexJobIdSet(asyncApexJobId).get(0);
        if(jobExecution.Batch_Finish__c == null){
            AsyncApexJob job = asyncApexJobRep.getAsyncApexJobListByIdSet(new Set<Id>{asyncApexJobId}).get(0);
            if(String.isEmpty(job.ExtendedStatus)){
                jobExecution.Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_FINISHED;
                
            }else{
                jobExecution.Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_FINISHED_ERRORS;
                
            }
            jobExecution.Batch_Finish__c = System.now();
    
            jobExecutionRep.updateSObjects(new List<Job_Execution__c>{jobExecution});
            
        }
    }

    /**
        *  @description:    Method to query the system
    */
    public Database.QueryLocator executeQuery(FW_QueryBuilder query){
        if(!String.isEmpty(getParameterValue(DEFAULT_PARAMETER))){
            query.whereIn('Id', (list<Object>)getParameterValue(DEFAULT_PARAMETER).split(','));
        }
        
        String countQuery = query.getCountQuery();
        Integer numberOfRecords = Database.countQuery(countQuery);
        
        if(numberOfRecords != null){
            jobExecution.Queried_Records__c = numberOfRecords;
            jobExecutionRep.updateSObjects(new List<Job_Execution__c>{jobExecution});
        }

        return Database.getQueryLocator(query.getQuery());
    }
}