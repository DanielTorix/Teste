/**
* @description   BactJob to delete leads where GDPR is set as No
* @testClass     Async_DeleteLeadsGDPRTest
* @ScheduleClass Async_DeleteLeadsGDPRSchedule
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme charro              04/10/2021          Created batchjob
* ------------------------------------------------------------------------------------ 
*/
global class Async_DeleteLeadsGDPR extends FW_AsyncHandler implements Database.Batchable<sObject>, Database.stateful{
    private IREP_Lead leadRepository;

    global Async_DeleteLeadsGDPR(){
        leadRepository = new REP_Lead();
    }

    @testVisible
    private Async_DeleteLeadsGDPR(IREP_Lead leadRepository,FW_IREP_JobExecution jobExecutionRep, FW_IREP_Parameters parameterRep){
        this.leadRepository = leadRepository;
        this.jobExecutionRep = jobExecutionRep;
        this.parameterRep = parameterRep;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        setAsyncApexJobId(bc.getJobId());

        FW_QueryBuilder query = new FW_QueryBuilder(Lead.SObjectType)
        .selectFields(REP_Lead.LEAD_FIELDS)
        .SetWhere('GeneralGDPR__c = \''+DO_Lead.LEAD_GDPR_NO+'\'');
        
        return executeQuery(query);
    }

    global void execute(Database.BatchableContext bc, List<Lead> leadList) {
        if (!leadList.isEmpty()) {
            leadRepository.deleteSObjects(leadList);
        }
    }

    global void finish(Database.BatchableContext bc) {
        finishBatch(bc.getJobId());
    }
}