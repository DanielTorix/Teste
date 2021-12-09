/**
* @description   Lead trigger handler class 
* @testClass     TH_LeadTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               26/05/2021          Created Lead Trigger handler
* Hugo Rodrigues               13/10/2021          Added TW_LeadContactMapping
* ------------------------------------------------------------------------------------ 
*/
public class TH_Lead extends FW_TriggerHandler{
    private List<Lead> newList;
    private Map<Id,Lead> oldMap;
    
    //create a new List a an old Map to use on the worker
    public TH_Lead(){
        this.newList = (List<Lead>) Trigger.New;
        this.oldMap = (Map<Id,Lead>) Trigger.OldMap;
    }
    
    protected override void executeAfterUpdate() {
         //calling the worker and sending the List and the Map
        
        new TW_LeadAccountMapping().execute(newList,oldMap);
        new TW_LeadContactMapping().execute(newList,oldMap);
        new TW_Lead_CheckGDPR().execute(newList,oldMap);
    }

    protected override void executeBeforeInsert() {
        new TW_Lead_FillComplementaryFields().execute(newList,null);
        new TW_Lead_CheckDataEncrypted().execute(newList);
    }

    protected override void executeBeforeUpdate() {
        new TW_Lead_FillComplementaryFields().execute(newList,oldMap);
        new TW_Lead_CheckFilesAttached().execute(newList, oldMap);
        new TW_Lead_ChangeOwnerNotification().execute(newList,oldMap);
    }
}