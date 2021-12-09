/**
* @description   Event trigger handler
* @testClass     TH_EventTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                10/11/2021          Created Event Handler
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TH_Event extends FW_TriggerHandler{
    private List<Event> newList;
    private Map<Id,Event> oldMap;

    public TH_Event(){
        this.newList = (List<Event>) Trigger.New;
        this.oldMap = (Map<Id,Event>) Trigger.OldMap;
    }

    protected override void executeAfterInsert() {
        new TW_Event_SetContactRelatedActivity().execute(newList);
    }

    protected override void executeAfterUpdate() {
        new TW_Event_SetContactRelatedActivity().execute(newList);
    }
}