/**
* @description   Opportunity trigger handler
* @testClass     TH_OpportunityTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                21/07/2021          Created Opportunity Handler
* ------------------------------------------------------------------------------------ 
*/
public class TH_Opportunity extends FW_TriggerHandler{
    private List<Opportunity> newList;
    private Map<Id,Opportunity> oldMap;

    public TH_Opportunity(){
        this.newList = (List<Opportunity>) Trigger.New;
        this.oldMap = (Map<Id,Opportunity>) Trigger.OldMap;
    }

    protected override void executeBeforeInsert() {
        new TW_Opportunity_FillPricebook().execute(newList);
        new TW_Opp_FillComplementaryFields().execute(newList, null);
    }

    protected override void executeBeforeUpdate() {
        new TW_Opp_FillComplementaryFields().execute(newList, oldMap);
    }

    protected override void executeAfterUpdate() {
        new TW_Opp_SetContactRelatedActivity().execute(newList);
    }
}