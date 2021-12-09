/**
* @description   Task trigger handler
* @testClass     TH_TaskTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                10/11/2021          Created Task Handler
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TH_Task extends FW_TriggerHandler{
    private List<Task> newList;
    private Map<Id,Task> oldMap;

    public TH_Task(){
        this.newList = (List<Task>) Trigger.New;
        this.oldMap = (Map<Id,Task>) Trigger.OldMap;
    }

    protected override void executeAfterInsert() {
        new TW_Task_SetContactRelatedActivity().execute(newList);
    }

    protected override void executeAfterUpdate() {
        new TW_Task_SetContactRelatedActivity().execute(newList);
    }
}