/**
* @description   Contact trigger handler class 
* @testClass     TH_ContactTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               26/05/2021          Created Contact Trigger handler
* ------------------------------------------------------------------------------------ 
*/
public class TH_Contact extends FW_TriggerHandler{
    private List<Contact> newList;
    private Map<Id,Contact> oldMap;
    
    //create a new List a an old Map to use on the worker
    public TH_Contact(){
        this.newList = (List<Contact>) Trigger.New;
        this.oldMap = (Map<Id,Contact>) Trigger.OldMap;
    }

    protected override void executeAfterUpdate() {
        new TW_Contact_CheckGDPR().execute(newList, oldMap);
    }

    protected override void executeBeforeInsert() {
        new TW_Contact_CheckDataEncrypted().execute(newList);
        new TW_Contact_SetContactRelatedActivity().execute(newList);
        new TW_Contact_FillComplementaryFields().execute(newList, oldMap);
    }

    protected override void executeBeforeUpdate(){
        new TW_Contact_CheckFilesAttached().execute(newList, oldMap);
        new TW_Contact_SetContactRelatedActivity().execute(newList);
        new TW_Contact_FillComplementaryFields().execute(newList, oldMap);
    }
}