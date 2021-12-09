/**
* @description   Account trigger handler
* @testClass     TH_AccountTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                06/09/2021          Created Trigger Handler
* ------------------------------------------------------------------------------------ 
*/
public class TH_Account extends FW_TriggerHandler{
    private List<Account> newList;
    private Map<Id,Account> oldMap;

    public TH_Account(){
        this.newList = (List<Account>) Trigger.New;
        this.oldMap = (Map<Id,Account>) Trigger.OldMap;
    }
    
    protected override void executeAfterUpdate() {
        new TW_Account_UpdateRelatedObjectsCountry().execute(newList, oldMap);
    }

    protected override void executeBeforeInsert() {
        new TW_Account_FillComplementaryFields().execute(newList, null);
    }

    protected override void executeBeforeUpdate() {
        new TW_Account_FillComplementaryFields().execute(newList, oldMap);
    }
}