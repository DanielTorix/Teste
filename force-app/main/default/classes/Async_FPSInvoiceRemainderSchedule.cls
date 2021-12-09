/**
* @description   Schedule for Async_FPSInvoiceRemainder
* @testClass     Async_FPSInvoiceRemainderScheduleTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Carolina Resende                28/11/2021          Created Schedule for Async_FPSInvoiceRemainder
* ------------------------------------------------------------------------------------ 
*/

global with sharing class Async_FPSInvoiceRemainderSchedule implements Schedulable {

    private FW_IREP_BatchDefinition batchDefRep;
    private FW_IREP_JobExecution jobExecutionRep;
    private FW_IDO_JobExecution jobExecutionDO;

    global Async_FPSInvoiceRemainderSchedule() {
        this.batchDefRep = new FW_REP_BatchDefinition();
        this.jobExecutionRep = new FW_REP_JobExecution();
        this.jobExecutionDO = new FW_DO_JobExecution();

    }

    @testVisible
    private Async_FPSInvoiceRemainderSchedule(FW_IREP_BatchDefinition batchDefRep, FW_IREP_JobExecution jobExecutionRep, FW_IDO_JobExecution jobExecutionDO) {

        this.batchDefRep = batchDefRep;
        this.jobExecutionRep = jobExecutionRep; 
        this.jobExecutionDO = jobExecutionDO;

    }
    global void execute(SchedulableContext sc) {
        List<Batch_Definition__c> bdList = batchDefRep.getBatchDefinitionByNameSet(new Set<String>{'FPSInvoiceRemainder'});

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
                            .setErrorMessage('Batch execution not found for FPSInvoiceRemainder at '+Datetime.now())
                            .setOrigin(String.valueOf(this))
                            .setCategory(FW_ErrorAndMonitoringLog.categoryType.Apex_Class)
                            .setActorId(UserInfo.getUserId())
                            .build();

        new FW_SystemNotificationPublr(errorLog);
    }
}