/**
* @description   Case trigger handler
* @testClass     TH_CaseTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                26/05/2021          Created Trigger Handler
* ------------------------------------------------------------------------------------ 
*/
public class TH_Case extends FW_TriggerHandler{
    private List<Case> newList;
    private Map<Id,Case> oldMap;
    private Map<Id,Case> newMap;


    public TH_Case(){
        this.newList = (List<Case>) Trigger.New;
        this.oldMap = (Map<Id,Case>) Trigger.OldMap;
        this.newMap = (Map<Id,Case>) Trigger.newMap;
    }
    
    protected override void executeAfterUpdate() {
        new TW_Case_CloseChildCases().execute(newList, oldMap);
        new TW_Case_HasOpenChildCases().execute(newList, oldMap);
        new TW_Case_SetContactRelatedActivity().execute(newList);
    }

    protected override void executeAfterInsert() {
        new TW_Case_HasOpenChildCases().execute(newList, null);
        new TW_Case_SetContactRelatedActivity().execute(newList);
    }

    protected override void executeBeforeInsert() {
        new TW_Case_FillComplementaryFields().execute(newList, null);
    }

    protected override void executeBeforeUpdate() {
        new TW_Case_FillComplementaryFields().execute(newList, oldMap);
        new TW_Case_UpdateWhenClosed().execute(newMap, oldMap);
        new TW_Case_ApprovalNotification().execute(newList, oldMap);
    }
}