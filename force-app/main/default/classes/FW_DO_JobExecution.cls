/**
    * @description   Job execution domain object class
    * @testClass     FW_DO_JobExecutionTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public inherited sharing class FW_DO_JobExecution implements FW_IDO_JobExecution {

    public final static String JOB_EXEC_STATUS_NEW = 'New';
    public final static String JOB_EXEC_STATUS_CANCELLED = 'Cancelled';
    public final static String JOB_EXEC_STATUS_STARTED = 'Started';
    public final static String JOB_EXEC_STATUS_SCHEDULED = 'Scheduled';
    public final static String JOB_EXEC_STATUS_FINISHED = 'Finished';
    public final static String JOB_EXEC_STATUS_FINISHED_ERRORS = 'Finished_with_Errors';
    public final static String JOB_EXEC_RECORD_TYPE_INITIAL = 'Initial';
    public final static String JOB_EXEC_RECORD_TYPE_DEFINED = 'Defined';

    /**
        * @description:    Method to clone a parameter and set JobExectutionId
    */
    public Parameters__c getClonedParameter(Parameters__c parameter, Id jobExecutionId){
        Parameters__c clonedParameter = parameter.clone(false, false);
        clonedParameter.Batch_Definition__c = null;
        clonedParameter.Job_Execution__c = jobExecutionId;
        return clonedParameter;
    }
    
    /**
        * @description:    Checks if execute field is checked
    */
    public Boolean isToExecute(Job_Execution__c jobExecution){
        return jobExecution.Execute__c;
    }

    /**
        * @description:    Checks if execute field is checked
    */
    public Boolean isScheduledRun(Job_Execution__c jobExecution){
        return jobExecution.Is_Scheduled_run__c;
    }

    /**
        * @description:    Checks if Job Execution job size is equals to the Batch Definition job size
    */
    public Boolean isJobSizeEqualsToBatchDefinitionJobSize(Job_Execution__c jobExecution, Batch_Definition__c batchDefinition) {
        return jobExecution.Job_Size__c == batchDefinition.Job_Size__c;
    }

    /**
        * @description:    Checks if the Job Execution is checked to run with default parameters
    */
    public Boolean isRunningwithDefaults(Job_Execution__c jobExecution) {
        return jobExecution.Run_with_Defaults__c;
    }
    
    /**
        * @description:    execute a batch job
    */
    public Id executeBatch(Job_Execution__c jobExecution, Batch_Definition__c batchDefinition) {
        Type customType = Type.forName(batchDefinition.Class_Name__c);

        FW_IAsync batchInterface = (FW_IAsync) customType.newInstance();

        batchInterface.setJobExecutionId(jobExecution.Id);

        return Database.executeBatch(
            (Database.Batchable<SObject>)batchInterface, 
            (Integer)jobExecution.Job_Size__c
        );
    }

    /**
        * @description:    Schedule a batch job
    */
    public Id scheduleBatch(Job_Execution__c jobExecution, Batch_Definition__c batchDefinition) {

        Type customType = Type.forName(batchDefinition.Class_Name__c);

        FW_IAsync batchInterface = (FW_IAsync) customType.newInstance();        
        batchInterface.setJobExecutionId(jobExecution.Id);
        
        return System.scheduleBatch(
                                    (Database.Batchable<SObject>)batchInterface,
                                    'Scheduled Job -' + String.valueOf(jobExecution.Scheduled_Execution_DateTime__c) + ' - ' + batchDefinition.Batch_Name__c,
                                    getDifferenceInMinutesFromNow(jobExecution.Scheduled_Execution_DateTime__c),
                                    (Integer)jobExecution.Job_Size__c
                                   );

    }

    /**
        * @description:    Returns the difference between current time and a given DateTime
    */
    public Integer getDifferenceInMinutesFromNow(DateTime dt1) {
        return (Integer)((dt1.getTime() - Datetime.now().getTime()) / 60000) + 1;
    }

    /**
        *  @description:    Returns the difference between current time and a given DateTime
    */
    public Job_Execution__c createJobExecutionsFromBD(Id batchDefinitionID){
    
        return new Job_Execution__c(
                    Batch_Definition__c = batchDefinitionID,
                    Is_Scheduled_run__c = true
                );
    }
    
    /**
        * @description:    abort a running job by specified ID
    */ 
    public void abortJob(String asyncId){
        if(test.isRunningTest()){
            System.abortJob(asyncId);
        }
    }
    
}