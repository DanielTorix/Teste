trigger FW_JobExecutionTrigger on Job_Execution__c (after insert, before update, before insert) {
        new FW_TH_JobExecution().execute();
}