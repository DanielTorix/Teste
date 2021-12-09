/**
    * @description   Job_Execution trigger handler
    * @testClass     FW_TH_JobExecutionTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public class FW_TH_JobExecution  extends FW_TriggerHandler {

    private List<Job_Execution__c> newList;
    private Map<Id,Job_Execution__c> oldMap;

    public FW_TH_JobExecution(){
        this.newList = (List<Job_Execution__c>) Trigger.New;
        this.oldMap = (Map<Id,Job_Execution__c>) Trigger.OldMap;
    }

    protected override void executeBeforeUpdate() {
        new FW_TW_JobExecution_Validations().execute(newList,oldMap);
        new FW_TW_JobExecution_ManageBatchBefore().execute(newList); 
    }
    
    protected override void executeBeforeInsert() {
        new FW_TW_JobExecution_CopyBDConfig().execute(newList);
    }

    protected override void executeAfterInsert() {
        new FW_TW_JobExecution_CloneParameters().execute(newList);
        new FW_TW_JobExecution_ManageBatchAfter().execute(newList);
    }

}