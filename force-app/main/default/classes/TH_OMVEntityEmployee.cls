/**
* @description   OMV Entity Employee trigger handler class 
* @testClass     TH_OMVEntityEmployeeTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               20/10/2021          Created OMV Entity Employee Trigger handler
* ------------------------------------------------------------------------------------ 
*/
public class TH_OMVEntityEmployee extends FW_TriggerHandler{

    private List<OMVEntityEmployee__c> newList;
    private Map<Id,OMVEntityEmployee__c> oldMap;

    public TH_OMVEntityEmployee() {
        this.newList = (List<OMVEntityEmployee__c>) Trigger.New;
        this.oldMap = (Map<Id,OMVEntityEmployee__c>) Trigger.OldMap;
    }

    protected override void executeBeforeInsert() {
        new TW_OMVEntityEmployee_UpdateUniqueID().execute(newList,null);
    }

    protected override void executeBeforeUpdate() {
        new TW_OMVEntityEmployee_UpdateUniqueID().execute(newList,oldMap);
    }
    protected override void executeBeforeDelete() {
        new TW_OMVEntityEmployee_UpdateUniqueID().execute(newList,oldMap);
    }
}