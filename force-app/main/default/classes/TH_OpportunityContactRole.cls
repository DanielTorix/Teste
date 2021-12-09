/**
* @description   OpportunityContactRole trigger handler
* @testClass     TH_OpportunityContactRoleTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                09/11/2021          Created OpportunityContactRole Handler
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TH_OpportunityContactRole extends FW_TriggerHandler{
    private List<OpportunityContactRole> newList;
    private Map<Id,OpportunityContactRole> oldMap;

    public TH_OpportunityContactRole(){
        this.newList = (List<OpportunityContactRole>) Trigger.New;
        this.oldMap = (Map<Id,OpportunityContactRole>) Trigger.OldMap;
    }

    protected override void executeAfterInsert() {
        new TW_OppCont_SetContactRelatedActivity().execute(newList);
    }

    protected override void executeAfterUpdate() {
        new TW_OppCont_SetContactRelatedActivity().execute(newList);
    }
}