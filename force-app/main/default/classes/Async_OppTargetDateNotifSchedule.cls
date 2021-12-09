/**
* @description   Schedule for Async_OppTargetDateNotification
* @testClass     Async_OppChatterScheduleTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* João Lopes                      28/06/2021          Class Created
* ------------------------------------------------------------------------------------ 
*/

global class Async_OppTargetDateNotifSchedule implements Schedulable{

    private FW_IREP_BatchDefinition batchDefRep;
    private FW_IREP_JobExecution jobExecutionRep;
    private FW_IDO_JobExecution jobExecutionDO;

    global Async_OppTargetDateNotifSchedule() {
        this.batchDefRep = new FW_REP_BatchDefinition();
        this.jobExecutionRep = new FW_REP_JobExecution();
        this.jobExecutionDO = new FW_DO_JobExecution();

    }

    @testVisible
    private Async_OppTargetDateNotifSchedule(FW_IREP_BatchDefinition batchDefRep, FW_IREP_JobExecution jobExecutionRep, FW_IDO_JobExecution jobExecutionDO) {

        this.batchDefRep = batchDefRep;
        this.jobExecutionRep = jobExecutionRep;
        this.jobExecutionDO = jobExecutionDO;

    }
    global void execute(SchedulableContext sc) {
        List<Batch_Definition__c> bdList = batchDefRep.getBatchDefinitionByNameSet(new Set<String>{'OppTargetDateNotification'});

        if(bdList.isEmpty()){
            createErrorLog();
        }else{
            jobExecutionRep.insertSObjects(new list<Job_Execution__c>{jobExecutionDO.createJobExecutionsFromBD(bdList[0].id)});
        }

    }

    /**  
        *  @description:    Create an error log record
    **/ 
    private void createErrorLog(){
        FW_ErrorAndMonitoringLog errorLog = new FW_ErrorAndMonitoringLog.ErrorDetailsBuilder()
                            .setErrorMessage('Batch execution not found for CleanJobExecutions at '+Datetime.now())
                            .setOrigin(String.valueOf(this))
                            .setCategory(FW_ErrorAndMonitoringLog.categoryType.Apex_Class)
                            .setActorId(UserInfo.getUserId())
                            .build();

        new FW_SystemNotificationPublr(errorLog);
    }
}